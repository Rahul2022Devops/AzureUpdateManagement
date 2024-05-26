resource "azurerm_resource_group" "az_rg" {
  name     = "RG-DEMO-VM-May"
  location = "centralindia"
}

resource "azurerm_virtual_network" "az_vnet" {
  name                = "VNET-DEMO-VM-May"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name
}

resource "azurerm_subnet" "az_subnet" {
  name                 = "SUBNET-DEMO-VM-May"
  resource_group_name  = azurerm_resource_group.az_rg.name
  virtual_network_name = azurerm_virtual_network.az_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "az_interface" {
  name                = "INTERFACE-DEMO-VM-May"
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.az_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "az_nsg" {
  name                = "NSG-DEMO-VM-May"
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name

  security_rule {
    name                       = "RDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "az_nisga" {
  network_interface_id      = azurerm_network_interface.az_interface.id
  network_security_group_id = azurerm_network_security_group.az_nsg.id
}

resource "azurerm_windows_virtual_machine" "example" {
  name                  = "DEMO-VM-May"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  size                  = "Standard_DS1_v2"
  admin_username        = "adminuser"
  admin_password        = "P@ssw0rd1234!"
  network_interface_ids = [azurerm_network_interface.az_interface.id]
  availability_set_id   = azurerm_availability_set.az_av_set.id

  os_disk {
    name              = "example-os-disk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_availability_set" "az_av_set" {
  name                = "example-avset"
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name
  managed             = true
}
