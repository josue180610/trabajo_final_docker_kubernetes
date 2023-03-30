# az login
# az account set --subscription "<subscription-id>"

provider "azurerm" {
  features {}

}

resource "azurerm_resource_group" "this" {
  name     = "personal"
  location = var.region
}

/*Este archivo es un standard, un archivo auxiliar qeu sirve para definir el provider a utilizar y
el grupo de recursos a crear.*/