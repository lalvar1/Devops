provider "azurerm" {
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  subscription_id = "${var.subscription_id}"
  tenant_id       = "${var.tenant_id}"
  version = "=2.0.0"
  features {}
  skip_provider_registration = true
}

terraform {
  backend "azurerm" {
    resource_group_name  = "{var.resource_group_name}"
    storage_account_name = "{var.storage_account_name}"
    container_name       = "{var.container_name}"
    access_key           = "__STORAGE_ACCOUNT_ACCESS_KEY__"
     }
}