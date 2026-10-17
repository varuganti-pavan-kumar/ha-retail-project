# Create a resource group
resource "azurerm_resource_group" "ha_retail" {
  name     = var.project_name
  location = var.location
}

resource "azurerm_virtual_network" "ha_retail" {
  name                = "ha-retail-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.ha_retail.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "ha_retail" {
  name                 = "snet-appgateway"
  resource_group_name  = azurerm_resource_group.ha_retail.name
  virtual_network_name = azurerm_virtual_network.ha_retail.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "ha_retail_web" {
  name                 = "snet-web"
  resource_group_name  = azurerm_resource_group.ha_retail.name
  virtual_network_name = azurerm_virtual_network.ha_retail.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "ha_retail_app" {
  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.ha_retail.name
  virtual_network_name = azurerm_virtual_network.ha_retail.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_subnet" "ha_retail_db" {
  name                 = "snet-db"
  resource_group_name  = azurerm_resource_group.ha_retail.name
  virtual_network_name = azurerm_virtual_network.ha_retail.name
  address_prefixes     = ["10.0.4.0/24"]
}