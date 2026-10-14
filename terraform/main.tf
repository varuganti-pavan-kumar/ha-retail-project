
# Create a resource group
resource "azurerm_resource_group" "ha_retail" {
  name     = var.project_name
  location = var.location
}
