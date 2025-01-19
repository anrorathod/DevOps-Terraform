provider "azurerm" {
  features {}
  subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}

# Create an Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = "demodevacr"
  resource_group_name = var.rgname
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = false
}
