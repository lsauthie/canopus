/* Postgres */

#Create a network to host both subnets (the DB and the web application)
resource "azurerm_virtual_network" "default" {
  name                = "canopus-vnet"
  location            = local.az_location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

#Create subnet to host the DB
resource "azurerm_subnet" "default" {
  name                 = "canopus-subnet"
  virtual_network_name = azurerm_virtual_network.default.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "fs"

    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

#Create a network security group 
resource "azurerm_network_security_group" "default" {
  name                = "canopus-nsg"
  location            = local.az_location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#Connect the NSG and the network
resource "azurerm_subnet_network_security_group_association" "default" {
  subnet_id                 = azurerm_subnet.default.id
  network_security_group_id = azurerm_network_security_group.default.id
}

#Create a private DNS zone
resource "azurerm_private_dns_zone" "default" {
  name                = "canopus-pdz.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name

  depends_on = [azurerm_subnet_network_security_group_association.default]
}


#Create the DNS entry for our DB
resource "azurerm_private_dns_zone_virtual_network_link" "default" {
  name                  = "canopus-pdzvnetlink.com"
  private_dns_zone_name = azurerm_private_dns_zone.default.name
  virtual_network_id    = azurerm_virtual_network.default.id
  resource_group_name   = azurerm_resource_group.rg.name
}

#Create the DB server which is linked to a subnet and a DNS
#Note: the admin password is also created at this stage - this needs special attention
resource "azurerm_postgresql_flexible_server" "default" {
  name                   = "canopus-server"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = local.az_location
  version                = "13"
  delegated_subnet_id    = azurerm_subnet.default.id
  private_dns_zone_id    = azurerm_private_dns_zone.default.id
  administrator_login    = "adminTerraform"
  #administrator_password = "QAZwsx123" #hardcoded in step2
  administrator_password = random_password.password.result #dynamically generated and stored in keyvault in step 3
  zone                   = "1"
  storage_mb             = 32768
  sku_name               = "GP_Standard_D2s_v3"
  backup_retention_days  = 7

  depends_on = [azurerm_private_dns_zone_virtual_network_link.default]
}

#Create the DB on top of the server
resource "azurerm_postgresql_flexible_server_database" "default" {
  name      = "canopus-db"
  server_id = azurerm_postgresql_flexible_server.default.id
  collation = "en_US.UTF8"
  charset   = "UTF8"
}