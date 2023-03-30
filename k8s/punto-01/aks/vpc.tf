module "network" {
  source  = "Azure/network/azurerm"
  version = "~>3.0"

  resource_group_name = azurerm_resource_group.this.name
  address_space       = "10.52.0.0/16" // El espacio de direcciones que se usa en la red virtual. Puede proporcionar más de un espacio de direcciones.
  subnet_prefixes     = ["10.52.1.0/24", "10.52.2.0/24"]
  subnet_names        = ["subnet1", "subnet2"]
  depends_on          = [azurerm_resource_group.this]
}

/*Archivo principal para poder crear la red de azure, con todos sus componentes e IP.
Se termine de ejecutar siempre y cuando se cree primero el grupo de recursos que va a usar
de azure => depends_on = [azurerm_resource_group.this]*/