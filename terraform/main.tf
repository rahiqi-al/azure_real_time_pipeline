provider "azurerm" {
  features {}
  subscription_id = "59b3f2eb-caba-469e-afca-cde678d49c24"
  resource_provider_registrations = "none"
}

# Reference existing resource group
data "azurerm_resource_group" "rtpipeline_rg" {
  name = "arahiqi"
}

# Event Hubs
resource "azurerm_eventhub_namespace" "rtpipeline_eh_ns" {
  name                = "rtpipeline-eh-ns"
  resource_group_name = data.azurerm_resource_group.rtpipeline_rg.name
  location            = data.azurerm_resource_group.rtpipeline_rg.location
  sku                 = "Standard"
  capacity            = 1
}

resource "azurerm_eventhub" "rtpipeline_eh" {
  name                = "rtpipeline-eh"
  namespace_id        = azurerm_eventhub_namespace.rtpipeline_eh_ns.id
  partition_count     = 2
  message_retention   = 1
}

# Azure Functions (requires a storage account for runtime)
resource "azurerm_storage_account" "rtpipeline_fn_storage" {
  name                     = "rtpipelinefn1234" # Must be globally unique
  resource_group_name      = data.azurerm_resource_group.rtpipeline_rg.name
  location                 = data.azurerm_resource_group.rtpipeline_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "rtpipeline_fn_plan" {
  name                = "rtpipeline-fn-plan"
  resource_group_name = data.azurerm_resource_group.rtpipeline_rg.name
  location            = data.azurerm_resource_group.rtpipeline_rg.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "rtpipeline_fn" {
  name                       = "rtpipeline-fn"
  resource_group_name        = data.azurerm_resource_group.rtpipeline_rg.name
  location                   = data.azurerm_resource_group.rtpipeline_rg.location
  service_plan_id            = azurerm_service_plan.rtpipeline_fn_plan.id
  storage_account_name       = azurerm_storage_account.rtpipeline_fn_storage.name
  storage_account_access_key = azurerm_storage_account.rtpipeline_fn_storage.primary_access_key

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "python"
    "EVENT_HUB_CONNECTION"     = azurerm_eventhub_namespace.rtpipeline_eh_ns.default_primary_connection_string
    "COSMOS_DB_ENDPOINT"       = azurerm_cosmosdb_account.rtpipeline_cosmosdb.endpoint
    "COSMOS_DB_KEY"            = azurerm_cosmosdb_account.rtpipeline_cosmosdb.primary_key
    "TEXT_ANALYTICS_ENDPOINT"  = azurerm_cognitive_account.rtpipeline_text_analytics.endpoint
    "TEXT_ANALYTICS_KEY"       = azurerm_cognitive_account.rtpipeline_text_analytics.primary_access_key
    "SLACK_WEBHOOK_URL"        = var.slack_webhook_url
  }

  site_config {
    application_stack {
      python_version = "3.9"
    }
  }
}

# Cosmos DB
resource "azurerm_cosmosdb_account" "rtpipeline_cosmosdb" {
  name                = "rtpipeline-cosmosdb"
  resource_group_name = data.azurerm_resource_group.rtpipeline_rg.name
  location            = data.azurerm_resource_group.rtpipeline_rg.location
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"
  consistency_policy {
    consistency_level = "Session"
  }
  geo_location {
    location          = data.azurerm_resource_group.rtpipeline_rg.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "rtpipeline_cosmosdb_db" {
  name                = "reviewsdb"
  resource_group_name = data.azurerm_resource_group.rtpipeline_rg.name
  account_name        = azurerm_cosmosdb_account.rtpipeline_cosmosdb.name
}

resource "azurerm_cosmosdb_sql_container" "rtpipeline_cosmosdb_container" {
  name                = "reviews"
  resource_group_name = data.azurerm_resource_group.rtpipeline_rg.name
  account_name        = azurerm_cosmosdb_account.rtpipeline_cosmosdb.name
  database_name       = azurerm_cosmosdb_sql_database.rtpipeline_cosmosdb_db.name
  partition_key_paths = ["/id"]
}

# Cognitive Services (Text Analytics)
resource "azurerm_cognitive_account" "rtpipeline_text_analytics" {
  name                = "rtpipeline-text-an"
  resource_group_name = data.azurerm_resource_group.rtpipeline_rg.name
  location            = data.azurerm_resource_group.rtpipeline_rg.location
  kind                = "TextAnalytics"
  sku_name            = "S"
}

# Logic Apps
resource "azurerm_logic_app_workflow" "rtpipeline_logic_app" {
  name                = "rtpipeline-logic-app"
  resource_group_name = data.azurerm_resource_group.rtpipeline_rg.name
  location            = data.azurerm_resource_group.rtpipeline_rg.location
}

# Variable for Slack webhook
variable "slack_webhook_url" {
  description = "Slack webhook URL for notifications"
  type        = string
  sensitive   = true
}

# Outputs
output "event_hub_connection_string" {
  value     = azurerm_eventhub_namespace.rtpipeline_eh_ns.default_primary_connection_string
  sensitive = true
}
output "cosmosdb_endpoint" {
  value = azurerm_cosmosdb_account.rtpipeline_cosmosdb.endpoint
}
output "function_app_name" {
  value = azurerm_linux_function_app.rtpipeline_fn.name
}