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
  client_secret   = "sjz8Q~WWyyR6Tt5IC9XtweesSBMlGQO-B-GNbcwI"
  tenant_id       = "3f1ad11d-be94-448d-b44b-77fd3a8dbc97"
}
