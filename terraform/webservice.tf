/* Webservice */

#Create the Linux App Service Plan
resource "azurerm_app_service_plan" "appserviceplan" {
  name                = "canopus-webapp-plan"
  location            = local.az_location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "Linux"
  reserved			  = true
  sku {
    tier = "Basic"
    size = "B1"
  }
}


# Create the web app, pass in the App Service Plan ID
# Note the app settings
resource "azurerm_app_service" "webapp" {
  name                = "canopus-webapp"
  location            = local.az_location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.appserviceplan.id
  app_settings 		  = {SCM_DO_BUILD_DURING_DEPLOYMENT = "1", DBUSER = "adminTerraform", DBPASS = "QAZwsx123", DBSERVER = "canopus-server"}
    
  #this must be set for a linux host
  site_config {                                                            
     linux_fx_version = "PYTHON|3.9"                                        
  }
}

# Add a subnet for the webservice - this is necessary to allow the webservice to talk to the DB
resource "azurerm_subnet" "default2" {
  name                 = "canopus-subnet2"
  virtual_network_name = azurerm_virtual_network.default.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.Web"]

  delegation {
    name = "fs1"

    service_delegation {
      name = "Microsoft.Web/serverFarms"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
  
}

# Connect the web application with the subnet
resource "azurerm_app_service_virtual_network_swift_connection" "example" {
  app_service_id = azurerm_app_service.webapp.id
  subnet_id      = azurerm_subnet.default2.id
}