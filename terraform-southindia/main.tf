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

resource "azurerm_network_security_group" "web" {
  name                = "nsg-web"
  location            = azurerm_resource_group.ha_retail.location
  resource_group_name = azurerm_resource_group.ha_retail.name

  security_rule {
    name                       = "AllowHTTPSFromAppGateway"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.0.1.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyOtherVnetInbound"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "web" {
  subnet_id                 = azurerm_subnet.ha_retail_web.id
  network_security_group_id = azurerm_network_security_group.web.id
}

resource "azurerm_network_security_group" "app" {
  name                = "nsg-app"
  location            = azurerm_resource_group.ha_retail.location
  resource_group_name = azurerm_resource_group.ha_retail.name

  security_rule {
    name                       = "AllowWebToApp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "10.0.2.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyOtherVnetInbound"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.ha_retail_app.id
  network_security_group_id = azurerm_network_security_group.app.id
}

resource "azurerm_network_security_group" "db" {
  name                = "nsg-db"
  location            = azurerm_resource_group.ha_retail.location
  resource_group_name = azurerm_resource_group.ha_retail.name

  security_rule {
    name                       = "AllowAppToPostgreSQL"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "10.0.3.0/24"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyOtherVnetInbound"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "db" {
  subnet_id                 = azurerm_subnet.ha_retail_db.id
  network_security_group_id = azurerm_network_security_group.db.id
}


# Network adapter for the web VM
resource "azurerm_network_interface" "web" {
  name                = "${var.project_name}-web-nic"
  location            = azurerm_resource_group.ha_retail.location
  resource_group_name = azurerm_resource_group.ha_retail.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.ha_retail_web.id
    private_ip_address_allocation = "Dynamic"
  }
}


# Linux web server virtual machine
resource "azurerm_linux_virtual_machine" "web" {
  name                = "${var.project_name}-web-vm"
  resource_group_name = azurerm_resource_group.ha_retail.name
  location            = azurerm_resource_group.ha_retail.location
  size                = "Standard_B2ats_v2"

  admin_username                  = "azureuser"
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.web.id
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("${pathexpand("~")}/.ssh/ha-retail-vm.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
