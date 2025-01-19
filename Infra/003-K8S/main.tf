provider "azurerm" {
  features {}
  subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-k8s-rg"
  location = var.location
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "${var.prefix}-k8s"
  kubernetes_version  = "1.30"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.prefix}-k8s"
  sku_tier            = "Free"
  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }
}
