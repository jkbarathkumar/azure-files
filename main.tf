
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
  backend "azurerm" {
      resource_group_name  = "dev-tfstate"
      storage_account_name = "devbackendtfstatehdwua"
      container_name       = "dev-tfstate-blob"
      key                  = "terraform.tfstate"
  }

}

provider "azurerm" {
  features {}
}


resource "random_string" "resource_code" {
  length  = 5
  special = false
  upper   = false
}

resource "azurerm_resource_group" "tfstate" {
  name     = "dev-tfstate"
  location = "central india"
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "devbackendtfstate${random_string.resource_code.result}"
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_nested_items_to_be_public = false

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "dev-tfstate-blob"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}



resource "azurerm_resource_group" "example" {
  name     = "barath-demo"
  location = "centralindia"
}

resource "azurerm_virtual_network" "example" {
  name                = "barath-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}
 
resource "azurerm_subnet" "example" {
  name                 = "barath-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}
 
resource "azurerm_public_ip" "public_ip" {
  name                = "barath-public-ip"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method = "Static"
}
 
resource "azurerm_network_interface" "example" {
  name                = "barath-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
 
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}
 
 
resource "azurerm_linux_virtual_machine" "example" {
  name                = "barath-machine"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_F2"
  admin_username      = "User15"
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]
 
  admin_ssh_key {
    username   = "User15"
    public_key = file("/home/user15/.ssh/id_rsa.pub")
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
 
  tags = {
    Name = "dev"
  }
}
