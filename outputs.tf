output "project_id" {
  value = var.project_id
  description = "Project ID"
}

output "app_name" {
  value = hcp_vault_secrets_app.example.app_name
  description = "App Name"
}

output "app_description" {
  value = hcp_vault_secrets_app.example.description
  description = "App Description"
}

output "service_principal_name" {
  value = hcp_service_principal.example.resource_name
  description = "Service Principal Name"
}

output "client_id" {
  value = hcp_service_principal_key.key.client_id
  description = "Client ID"
}

# after running "tf apply", "terraform output -raw client_secret" returns the client_secret
output "client_secret" {
  value = hcp_service_principal_key.key.client_secret
  description = "Client Secret"
  sensitive = true  
}

# after running "tf apply", "terraform output -json map_of_secrets" returns the map
output "map_of_secrets" {
  value = data.hcp_vault_secrets_app.example.secrets
  description = "Map of Secrets in the app"
  sensitive = true  
}
