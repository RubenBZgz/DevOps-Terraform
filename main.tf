terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.86.0"
    }
  }

  /*  Remote Backend Incoming
  backend "azurerm" {
    resource_group_name  = "TerraformRG"
    storage_account_name = "storageaccountname"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }*/
}

#https://learn.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure?tabs=bash
provider "azurerm" {
  #skip_provider_registration = "true"
  features {}
  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_tenant_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
}

/*En este archivo.tf se está creando la estructura de 
https://learn.microsoft.com/es-es/azure/architecture/web-apps/idea/scalable-ecommerce-web-app

Requisitos:
0. Mejores prácticas

Hecho:

En proceso:
1. Creación de todos los objetos.
2. Mirar la conexión entre ellos.
3. Optimización de propiedades sin alterar la arquitectura. Ej: Blob stg hot, cold...
4. Localización de fallos y de posibles mejoras.

Falta pasar la website al web app
*/


locals {
  name = "LocalVariable"
  tags = {
    environment = "Lab"
  }
}

resource "azurerm_resource_group" "this" {
  name     = var.rsgname
  location = var.location

  tags = local.tags
}


resource "azurerm_storage_account" "this" {
  name                     = var.stgactname
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = var.replication_type

  tags = local.tags
}

resource "azurerm_service_plan" "this" {
  name                = "linux-service-plan"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  os_type             = "Linux"
  sku_name            = "P1v2"
}

# Mirar la escalabilidad
# Posible introducción de elegir Linux y Windows
resource "azurerm_linux_web_app" "this" {
  name                = "linux-web-app"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_service_plan.this.location
  service_plan_id     = azurerm_service_plan.this.id

  site_config {}
  
}

# Aquí se puede implementar un For Each.
resource "azurerm_linux_web_app_slot" "pro" {
  name           = "production"
  app_service_id = azurerm_linux_web_app.this.id

  site_config {}
}

resource "azurerm_linux_web_app_slot" "dev" {
  name           = "development"
  app_service_id = azurerm_linux_web_app.this.id

  site_config {}
}

# PENDIENTE
resource "azurerm_mssql_server" "example" {
  name                         = "mssqlserver"
  resource_group_name          = azurerm_resource_group.this.name
  location                     = azurerm_resource_group.this.location
  version                      = "12.0"
  administrator_login          = "missadministrator"
  administrator_login_password = "thisIsKat11"
  minimum_tls_version          = "1.2"

  azuread_administrator {
    login_username = "AzureAD Admin"
    object_id      = "00000000-0000-0000-0000-000000000000"
  }

  tags = {
    environment = "production"
  }
}

#<--------------------OUTPUT-------------------->
output "azurerm_storage_account" {
  value = azurerm_storage_account.this.name
}

output "default_website_url" {
  value = "${azurerm_linux_web_app.this.name}.azurewebsites.net"
}
