variable "project_id" {
  description = "The project ID for the HVS app"
  type = string
}

variable "app_name" {
  description = "The app name for the HVS app"
  type = string
  default = "example-app"
}

variable "app_description" {
  description = "The app description for the HVS app"
  type = string
  default = "Some description for the app"
}

variable "service-principal-prefix" {
  description = "The prefix for the service principal"
  type = string
  default = "sp"  
}
