/* KeyVault */

#Create the azure KeyVault - note that the name must be globally unique. We also define the policies which are needed.
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "example" {
  name                        = "dole8953-keyvault"
  location                    = local.az_location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  #Access policy for the current user which is logged in
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get","List", "Set", "Delete","Recover", "Backup", "Restore", "Purge"
    ]

    storage_permissions = [
      "Get",
    ]
  }

  #Access policy for the webapplication
  access_policy {
	tenant_id = data.azurerm_client_config.current.tenant_id
	object_id = azurerm_app_service.webapp.identity.0.principal_id
	
	key_permissions = [
	  "Get",
	]

	secret_permissions = [
	  "Get",
	]

	storage_permissions = [
	  "Get",
	]
  }
}

#Generate a random pwd
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

#Set secret for our postgres DB
resource "azurerm_key_vault_secret" "example" {
  name         = "secret-sauce"
  value        = random_password.password.result
  key_vault_id = azurerm_key_vault.example.id
}

#Set RBAC for application
#https://stackoverflow.com/questions/64620218/get-azure-managed-identity-id-with-terraform
resource "azurerm_role_assignment" "example" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Reader"
  principal_id         = azurerm_app_service.webapp.identity.0.principal_id
  
  depends_on = [
	azurerm_resource_group.rg,
	azurerm_app_service.webapp
  ]
}
