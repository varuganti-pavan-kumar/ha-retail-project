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

  service_endpoints = ["Microsoft.KeyVault"]
}

resource "azurerm_network_security_group" "web" {
  name                = "nsg-web"
  location            = azurerm_resource_group.ha_retail.location
  resource_group_name = azurerm_resource_group.ha_retail.name

  security_rule {
    name                       = "AllowHTTPFromAppVNet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "VirtualNetwork"
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


# Application tier network interface
resource "azurerm_network_interface" "app" {
  name                = "${var.project_name}-app-nic"
  location            = azurerm_resource_group.ha_retail.location
  resource_group_name = azurerm_resource_group.ha_retail.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.ha_retail_app.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Application tier VM
resource "azurerm_linux_virtual_machine" "app" {
  name                = "${var.project_name}-app-vm"
  resource_group_name = azurerm_resource_group.ha_retail.name
  location            = azurerm_resource_group.ha_retail.location
  size                = "Standard_B2ats_v2"

  admin_username                  = "azureuser"
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.app.id]

  identity {
    type = "SystemAssigned"
  }

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

# UK South resource group for managed PostgreSQL
resource "azurerm_resource_group" "postgresql" {
  name     = "${var.project_name}-postgresql-uksouth"
  location = "uksouth"
}

# UK South VNet for PostgreSQL private access
resource "azurerm_virtual_network" "postgresql" {
  name                = "${var.project_name}-postgresql-vnet"
  location            = azurerm_resource_group.postgresql.location
  resource_group_name = azurerm_resource_group.postgresql.name
  address_space       = ["10.1.0.0/16"]
}


# Dedicated subnet for PostgreSQL Flexible Server
resource "azurerm_subnet" "postgresql" {
  name                 = "snet-postgresql"
  resource_group_name  = azurerm_resource_group.postgresql.name
  virtual_network_name = azurerm_virtual_network.postgresql.name
  address_prefixes     = ["10.1.1.0/24"]
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "postgresql-delegation"

    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

# South India to UK South peering
resource "azurerm_virtual_network_peering" "southindia_to_uksouth" {
  name                      = "southindia-to-uksouth"
  resource_group_name       = azurerm_resource_group.ha_retail.name
  virtual_network_name      = azurerm_virtual_network.ha_retail.name
  remote_virtual_network_id = azurerm_virtual_network.postgresql.id

  allow_virtual_network_access = true
}

# UK South to South India peering
resource "azurerm_virtual_network_peering" "uksouth_to_southindia" {
  name                      = "uksouth-to-southindia"
  resource_group_name       = azurerm_resource_group.postgresql.name
  virtual_network_name      = azurerm_virtual_network.postgresql.name
  remote_virtual_network_id = azurerm_virtual_network.ha_retail.id

  allow_virtual_network_access = true
}


# Private DNS zone for PostgreSQL Flexible Server
resource "azurerm_private_dns_zone" "postgresql" {
  name                = "${var.project_name}.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.postgresql.name
}

# Link DNS zone to the UK South VNet
resource "azurerm_private_dns_zone_virtual_network_link" "postgresql_uksouth" {
  name                  = "postgresql-dns-uksouth"
  resource_group_name   = azurerm_resource_group.postgresql.name
  private_dns_zone_name = azurerm_private_dns_zone.postgresql.name
  virtual_network_id    = azurerm_virtual_network.postgresql.id
  registration_enabled  = false
}

# Link DNS zone to the South India VNet
resource "azurerm_private_dns_zone_virtual_network_link" "postgresql_southindia" {
  name                  = "postgresql-dns-southindia"
  resource_group_name   = azurerm_resource_group.postgresql.name
  private_dns_zone_name = azurerm_private_dns_zone.postgresql.name
  virtual_network_id    = azurerm_virtual_network.ha_retail.id
  registration_enabled  = false
}


# Managed PostgreSQL server in UK South
resource "azurerm_postgresql_flexible_server" "postgresql" {
  name                = "${var.project_name}-pg"
  resource_group_name = azurerm_resource_group.postgresql.name
  location            = azurerm_resource_group.postgresql.location

  version    = "18"
  zone       = "3"
  sku_name   = "B_Standard_B2s"
  storage_mb = 32768

  administrator_login    = var.postgresql_admin
  administrator_password = var.postgresql_password

  delegated_subnet_id = azurerm_subnet.postgresql.id
  private_dns_zone_id = azurerm_private_dns_zone.postgresql.id

  public_network_access_enabled = false

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.postgresql_uksouth,
    azurerm_private_dns_zone_virtual_network_link.postgresql_southindia
  ]
}


# Read the current Azure subscription and tenant details
data "azurerm_client_config" "current" {}

# Azure Key Vault for application secrets
resource "azurerm_key_vault" "ha_retail" {
  name = "hrkv${substr(replace(data.azurerm_client_config.current.subscription_id, "-", ""), 0, 20)}"

  location            = azurerm_resource_group.ha_retail.location
  resource_group_name = azurerm_resource_group.ha_retail.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  rbac_authorization_enabled    = true
  soft_delete_retention_days    = 7
  purge_protection_enabled      = true
  public_network_access_enabled = true

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"

    virtual_network_subnet_ids = [
      azurerm_subnet.ha_retail_app.id
    ]
  }
}

# Allow the app VM to read secrets, but not manage them
resource "azurerm_role_assignment" "app_key_vault_secrets_user" {
  scope                = azurerm_key_vault.ha_retail.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_virtual_machine.app.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}
