# HCP Vault Secrets App with read-only Service Principal

This module provisions an HVS application and an associated
 HCP Service Principal and Key (Client ID and Client Secret) 
 with App Secret Reader permissions for the application.

Secrets for this application should be added separately in the 
 HCP Portal, CLI, or API so Terraform will not be the 
 source of truth for the secret values. Rather, HVS itself should 
 be the source of truth for the app secret values.

The Client ID and Client Secret in the ouptut can be used to read
secrets for this application with least priviledge.

*Note:* The HCP Service Principal Key will be rotated each time it
 is 30 days or older and `terraform apply` runs to completion.

 ## Usage

example main.tf using this module

 ```terraform
module "hvsapp" {
  source  = "jbayer/hvsapp/hcp"
  version = "1.0.7"
  # insert the 1 required variable here
  project_id = var.project_id
  
  # optional, defaults to example-app
  app_name = var.app_name
}

variable "project_id" {
  description = "The project ID for the HVS app"
  type = string
}

variable "app_name" {
  description = "The name for the HVS app"
  type = string
  default = "example-app"
}

output "project_id" {
  value = module.hvsapp.project_id
  description = "Project ID"
}

output "app_name" {
  value = module.hvsapp.app_name
  description = "App Name"
}

output "app_description" {
  value = module.hvsapp.app_description
  description = "App Description"
}

output "service_principal_name" {
  value = module.hvsapp.service_principal_name
  description = "Service Principal Name"
}

output "client_id" {
  value = module.hvsapp.client_id
  description = "Client ID"
}

# after running "tf apply", "terraform output -raw client_secret" returns the client_secret
output "client_secret" {
  value = module.hvsapp.client_secret
  description = "Client Secret"
  sensitive = true  
}

# after running "tf apply", "terraform output -json map_of_secrets" returns the map
output "map_of_secrets" {
  value = module.hvsapp.map_of_secrets
  description = "Map of Secrets in the app"
  sensitive = true  
}
```

## Example commands
```shell

# main.tf above should be in an empty directory

export PROJECT_ID=1111-2222-3333-4444

$ terraform init
$ terraform plan -var="project_id=$PROJECT_ID"
$ terraform apply -var="project_id=$PROJECT_ID"

# use the HCP Portal, CLI, or API to create secrets for the app
$ vlt login
$ vlt config init
$ vlt secrets create foo=somevalue

# Once secrets exist, you can refresh the state
$ terraform refresh -var="project_id=$PROJECT_ID"

# If the secrets exist
terraform output map_of_secrets

# Then you can use the Service Principal to read the secrets via API or CLI
terraform output client_id
terraform output client_secret

export HCP_CLIENT_ID=$(terraform output -raw client_id)
export HCP_CLIENT_SECRET=$(terraform output -raw client_secret)
export HCP_API_TOKEN=$(curl --location "https://auth.idp.hashicorp.com/oauth2/token" \
  --header "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "client_id=$HCP_CLIENT_ID" \
  --data-urlencode "client_secret=$HCP_CLIENT_SECRET" \
  --data-urlencode "grant_type=client_credentials" \
  --data-urlencode "audience=https://api.hashicorp.cloud" | jq -r .access_token)

# The vlt CLI does not when the principal only has secrets.app-secret-reader
# so we are going to use curl to read the secret instead
#
# setup the vlt CLI using the env vars for authentication
# choose the appropriate app
# if this does not have an interactive prompt, then run: 
# rm ~/.vlt.json
# and try the "vlt config init" command again
# vlt config init

# now you should be able to retrieve the secrets as
# capitalized environment variables. So if the secret
# name is foo, then you the secret value will be 
# associated with the FOO environment variable  
# vlt run -- env | grep FOO

curl -s -H "Authorization: Bearer $HCP_API_TOKEN" https://api.cloud.hashicorp.com/secrets/2023-11-28/organizations/11eab1a9-65ca-3c91-8be1-0242ac110016/projects/11eab1a9-65e9-7b03-adc9-0242ac11000a/apps/example-app/secrets/foo:open | jq .
{
  "secret": {
    "name": "foo",
    "type": "kv",
    "latest_version": 1,
    "created_at": "2024-05-10T23:43:38.196650Z",
    "created_by": {
      "name": "James Bayer",
      "type": "TYPE_USER",
      "email": "jbayer@example.com"
    },
    "sync_status": {},
    "static_version": {
      "version": 1,
      "value": "my super secret value",
      "created_at": "2024-05-10T23:43:38.196650Z",
      "created_by": {
        "name": "James Bayer",
        "type": "TYPE_USER",
        "email": "jbayer@example.com"
      }
    }
  }
}

# if you try this with an app that the Service Principal does not have access to
# then you get a 403 HTTP response code and a JSON payload with code=7
curl -s -H "Authorization: Bearer $HCP_API_TOKEN" https://api.cloud.hashicorp.com/secrets/2023-11-28/organizations/11eab1a9-65ca-3c91-8be1-0242ac110016/projects/11eab1a9-65e9-7b03-adc9-0242ac11000a/apps/app2/secrets/foo:open | jq .
{
  "code": 7,
  "message": "",
  "details": []
}

```