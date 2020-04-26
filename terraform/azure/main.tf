provider "azurerm" {
  version         = "=2.7.0"
  subscription_id = var.subscription_id
  features {
  }
}

resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

module "network" {
  source = "./modules/network"

  subscription_id         = var.subscription_id
  resource_group_name     = azurerm_resource_group.resource_group.name
  resource_group_location = azurerm_resource_group.resource_group.location
}

module "virtual_machines" {
  source = "./modules/virtual_machines"

  subscription_id         = var.subscription_id
  resource_group_name     = azurerm_resource_group.resource_group.name
  resource_group_location = azurerm_resource_group.resource_group.location
  nic_web_id              = module.network.nic_public_id
  nic_db_id               = module.network.nic_private_id
  vm_username             = var.vm_username
}

module "storage" {
  source = "./modules/storage"

  subscription_id         = var.subscription_id
  resource_group_name     = azurerm_resource_group.resource_group.name
  resource_group_location = azurerm_resource_group.resource_group.location
}

module "cdn" {
  source = "./modules/cdn"

  subscription_id         = var.subscription_id
  resource_group_name     = azurerm_resource_group.resource_group.name
  resource_group_location = azurerm_resource_group.resource_group.location
  storage_blog_host_name  = module.storage.storage_blog_host_name
}