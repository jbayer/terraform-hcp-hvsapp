# HCP Vault Secrets App with read-only Service Principal

This module provisions an HVS application and an associated
 HCP Service Principal and Key (Client ID and Client Secret) 
 with viewer permissions for the project.

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
  version = "1.0.4"
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

# setup the vlt CLI using the env vars for authentication
# choose the appropriate app
# if this does not have an interactive prompt, then run: 
# rm ~/.vlt.json
# and try the "vlt config init" command again
vlt config init

# now you should be able to retrieve the secrets as
# capitalized environment variables. So if the secret
# name is foo, then you the secret value will be 
# associated with the FOO environment variable  
vlt run -- env | grep FOO

```