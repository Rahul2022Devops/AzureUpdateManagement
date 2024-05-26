terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "2.92.0"
    }
  }
}
provider "azurerm" {
  features {}

  subscription_id = "8a24fe43-dfae-40d8-a480-95972e119947"
  client_id       = "e235661c-87e1-4f78-a404-5982e85a7eca"
  client_secret   = "57eaa259-e264-4f2e-b7e5-a1646f52f1da"
  tenant_id       = "3f1ad11d-be94-448d-b44b-77fd3a8dbc97"
}
