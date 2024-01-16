# Environment variables
variable "azure_client_id" {}
variable "azure_client_secret" {}
variable "azure_tenant_id" {}
variable "azure_subscription_id" {}


# Project variables

variable "location" {
  type        = string
  description = "Deployment location"
  default     = "West Europe"
}

variable "rsgname" {
  type        = string
  description = "Resource Group name"
  default     = "TerraformRG"
}

variable "stgactname" {
  type        = string
  description = "Storage Account name"
  default     = "storageaccountname"
}


variable "replication_type" {
  type        = string
  description = "Subscription replication type"
  default     = "GRS"
}
#terraform plan -var="stgactname=prueba"