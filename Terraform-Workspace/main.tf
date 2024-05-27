# Resource Group Creation
resource "azurerm_resource_group" "az_rg" {
  name     = "RG-DEMO-VM-May"
  location = "centralindia"
}
# Virtual Network Creation
resource "azurerm_virtual_network" "az_vnet" {
  name                = "VNET-DEMO-VM-May"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name
}
# Subnet Creation
resource "azurerm_subnet" "az_subnet" {
  name                 = "SUBNET-DEMO-VM-May"
  resource_group_name  = azurerm_resource_group.az_rg.name
  virtual_network_name = azurerm_virtual_network.az_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_public_ip" "az_publicip" {
  name                = "PUBLICIP-DEMO-VM-May"
  location            = "centralindia"
  resource_group_name = azurerm_resource_group.az_rg.name
  allocation_method   = "Dynamic"
}
# Network Interface Creation
resource "azurerm_network_interface" "az_interface" {
  name                = "INTERFACE-DEMO-VM-May"
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.az_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.az_publicip.id
  }
}
# Network Security Group Creation
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
# Network Security Association Creation
resource "azurerm_network_interface_security_group_association" "az_nisga" {
  network_interface_id      = azurerm_network_interface.az_interface.id
  network_security_group_id = azurerm_network_security_group.az_nsg.id
}
# VM Creation
resource "azurerm_windows_virtual_machine" "az_windows_vm" {
  name                  = "DEMO-VM-May"
  location              = azurerm_resource_group.az_rg.location
  resource_group_name   = azurerm_resource_group.az_rg.name
  size                  = "Standard_DS1_v2"
  admin_username        = "adminuser"
  admin_password        = "P@ssw0rd1234!"
  network_interface_ids = [azurerm_network_interface.az_interface.id]
  availability_set_id   = azurerm_availability_set.az_av_set.id

  os_disk {
    name              = "eaz_windows_vm-os-disk"
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
# Availability Set Creation
resource "azurerm_availability_set" "az_av_set" {
  name                = "AZ-AV-SET-DEMO-VM-May"
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name
  managed             = true
}


# adding these below code for log ananlytics & Update management
# Automation Account
resource "azurerm_automation_account" "az_automation_account" {
  name                = "AUTOMATION-ACCOUNT-DEMO-VM-May"
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name
  sku_name = "Basic"

}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "az_log_analytics_workspace" {
  name                = "LOG-DEMO-VM-May"
  location            = azurerm_resource_group.az_rg.location
  resource_group_name = azurerm_resource_group.az_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30  # Adjust retention period as needed
}

# Enable Update Management Solution
resource "azurerm_log_analytics_solution" "az_analytcs_solution" {
  solution_name                  = "LOG-SOLUTION-DEMO-VM-May"
  location              = azurerm_resource_group.az_rg.location
  resource_group_name   = azurerm_resource_group.az_rg.name
  workspace_resource_id = azurerm_log_analytics_workspace.az_log_analytics_workspace.id
  workspace_name        = azurerm_log_analytics_workspace.az_log_analytics_workspace.name
  plan {
    publisher = "Microsoft"
    # product   = "OMSGallery/Updates"
    product = "VMInsights" #explore
  }
  depends_on = [azurerm_log_analytics_workspace.az_log_analytics_workspace]
}
# AZ Log Analytics Linked Service Creation
resource "azurerm_log_analytics_linked_service" "az_log_linked_service" {
  resource_group_name = azurerm_resource_group.az_rg.name
  workspace_id = azurerm_log_analytics_workspace.az_log_analytics_workspace.id
  read_access_id = azurerm_automation_account.az_automation_account.id
  depends_on = [azurerm_log_analytics_solution.az_analytcs_solution]
}
resource "azurerm_virtual_machine_extension" "az_vm_extension" {
  name                 = "AZ-AGENT-DEMO-VM-May"
  virtual_machine_id   = azurerm_windows_virtual_machine.az_windows_vm.id
  publisher            = "Microsoft.Azure.Monitor"
  # publisher            = "Microsoft.Azure.Monitor"
  # type                 = "OmsAgentForLinux" #explore
  type                 = "AzureMonitorWindowsAgent" #explore
  # type_handler_version = "9.10"
  type_handler_version = "1.10"
  # auto_upgrade_minor_version = true
  automatic_upgrade_enabled = true
  settings = <<SETTINGS
    {
      "workspaceId": "${azurerm_log_analytics_workspace.az_log_analytics_workspace.workspace_id}"
    }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "workspaceKey": "${azurerm_log_analytics_workspace.az_log_analytics_workspace.primary_shared_key}"
    }
  PROTECTED_SETTINGS
}

# resource "azurerm_update_management_schedule" "az_update_management_schedule" {
#   name                    = "AZ-UPDATE-SCHEDULE-DEMO-VM-May"
#   resource_group_name     = azurerm_resource_group.az_rg.name
#   automation_account_name = azurerm_automation_account.az_automation_account.name

#   schedule_info {
#     frequency          = "Week"
#     interval           = 1
#     start_time         = "2024-01-01T18:00:00Z"
#     expiry_time        = "2026-01-01T18:00:00Z"
#     time_zone          = "UTC"
#     advanced_schedule {
#       week_days = ["Monday"]
#     }
#   }

#   update_configuration {
#     operating_system    = "Windows"
#     duration            = "PT2H"
#     reboot_setting      = "IfRequired"
#     azure_virtual_machine {
#       ids = azurerm_windows_virtual_machine.az_windows_vm.id
#     }
#   }
# }

# Add Virtual Machines to Update Management
# resource "azurerm_update_management_vm" "az_update_management" {
#   workspace_id = azurerm_log_analytics_workspace.az_log_analytics_workspace.id
#   vm_ids       = [azurerm_virtual_machine.az_windows_vm.id]  # Assuming you have a VM defined elsewhere in your Terraform configuration
# }

