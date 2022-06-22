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
  app_settings 		  = {SCM_DO_BUILD_DURING_DEPLOYMENT = "1"}
    
  #this must be set for a linux host
  site_config {                                                            
     linux_fx_version = "PYTHON|3.9"                                        
  }
  
}