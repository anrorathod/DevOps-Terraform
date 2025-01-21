# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

  features {}
}

# Locate the existing resource group
module "resource-group" {
  source              = "../../modules/resource-group"
  resource_group_name = var.resource_group_name
  location            = var.location
}

# Locate the existing custom image
data "azurerm_image" "main" {
  name                = "agentpool-np-packerimage"
  resource_group_name = "packer-vm-rg"
}



# Create a Network Security Group with some rules
resource "azurerm_network_security_group" "main" {
  name                = "demo-agent-np-agent-SG"
  location            = var.location
  resource_group_name = var.resource_group_name
  security_rule {
    name                       = "demo-agent-np-agent-SGR"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "80"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  depends_on = [module.resource-group]
}

# Create virtual network
resource "azurerm_virtual_network" "main" {
  name                = "demo-agent-np-agent-network"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
  depends_on          = [module.resource-group]
}

# Create subnet
resource "azurerm_subnet" "main" {
  name                 = "demo-agent-np-agent-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
  depends_on           = [module.resource-group]
}

# Create public IP
resource "azurerm_public_ip" "main" {
  name                = "demo-agent-np-agent-public-ip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"

  tags = {
    environment = "development"
  }
  depends_on = [module.resource-group]
}

# Create network interface
resource "azurerm_network_interface" "main" {
  name                = "demo-agent-np-agent-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  depends_on          = [module.resource-group]

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

# Create a new Virtual Machine based on the custom Image
resource "azurerm_virtual_machine" "myVM2" {
  depends_on                       = [module.resource-group]
  name                             = "demo-agent-np-agent-VM"
  location                         = var.location
  resource_group_name              = var.resource_group_name
  network_interface_ids            = ["${azurerm_network_interface.main.id}"]
  vm_size                          = "Standard_B2s"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    id = data.azurerm_image.main.id
  }

  storage_os_disk {
    name              = "demo-agent-np-agent-VM-OS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "demo-agent-np-agent-VM"
    admin_username = "devopsadmin"
    admin_password = "Cssladmin#2019"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }


  tags = {
    environment = "development"
  }
}
