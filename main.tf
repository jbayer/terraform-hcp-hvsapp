terraform {
  required_providers {
   hcp = {
      source  = "hashicorp/hcp"
      version = "0.88"
    }
    time = {
      source = "hashicorp/time"
      version = "0.11.1"
    }
  }
}

provider "hcp" {
  # Project ID for the HVS app
  # project_id = "11eab1a9-65e9-7b03-adc9-0242ac11000a"
  project_id = var.project_id
  # HCP_CLIENT_ID, HCP_CLIENT_SECRET are provided as environment variables 
  # in an HCP TF Variable Set associated with the HCP TF Workspace
}

resource "hcp_service_principal" "example" {
  name = join("-", [var.service-principal-prefix, var.app_name])
}

resource "time_rotating" "key_rotation" {
  rotation_days = 30
}

resource "hcp_service_principal_key" "key" {
  service_principal = hcp_service_principal.example.resource_name
  rotate_triggers = {
    "time_rotating" = time_rotating.key_rotation.rfc3339
  }
}

resource "hcp_vault_secrets_app" "example" {
  app_name    = var.app_name
  description = var.app_description
}

# Removing this as it did not work yet in HCP production
# 
# resource "hcp_vault_secrets_app_iam_binding" "example" {
#  resource_name = hcp_vault_secrets_app.example.resource_name
#  principal_id  = hcp_service_principal.example.resource_id
#  role          = "roles/secrets.app-secret-reader"
#}

resource "hcp_project_iam_binding" "example" {
  project_id   = var.project_id
  principal_id = hcp_service_principal.example.resource_id
  role         = "roles/viewer"
}

# TODO
# Removed the managing of secrets as secrets are probably best managed out of band
# 
# Instead, manage secret values via the HCP Portal, CLI, or API after
# the app has been created
# resource "hcp_vault_secrets_secret" "example" {
  # for_each = { for secret_name in var.secret_names : secret_name => {} }
  
#  secret_name  = each.key
#  app_name     = hcp_vault_secrets_app.example.app_name
#  secret_value = "replace_me_later"
#}

# Specify the app_name in the project (one app_name per data block)
# the .secrets attribute is a map of string values keyed by the secret name
data "hcp_vault_secrets_app" "example" {
  app_name = hcp_vault_secrets_app.example.app_name
}