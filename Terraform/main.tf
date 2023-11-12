provider "azurerm" {
  features {}
}
### -----------------------NETWORK--------------------- ###
# Creación de la red virtual
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix_name}-network"
  address_space       = ["10.0.0.0/16"]
  location            = var.region
  resource_group_name = var.resource_group_name
}

resource "azurerm_kubernetes_cluster" "twitter-aks" {
  name                             = "${var.prefix_name}-aks"
  location                         = var.region
  resource_group_name              = var.resource_group_name
  dns_prefix                       = "${var.prefix_name}-aks"
  default_node_pool {
    name                = "default"
    node_count          = 1
    vm_size             = "Standard_D2_v2"
    enable_auto_scaling = true
    max_count           = 3
    min_count           = 1
  }
  identity {
    type = "SystemAssigned"
  }
}

resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

resource "azurerm_cosmosdb_account" "db_account" {
  name                = "tfex-cosmos-db-${random_integer.ri.result}"
  location            = var.region
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "MongoDB"

  enable_automatic_failover = true

  capabilities {
    name = "EnableAggregationPipeline"
  }

  capabilities {
    name = "mongoEnableDocLevelTTL"
  }

  capabilities {
    name = "MongoDBv3.4"
  }

  capabilities {
    name = "EnableMongo"
  }

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }

  geo_location {
    location          = "eastus"
    failover_priority = 1
  }

  geo_location {
    location          = "westus"
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_mongo_database" "twitter-db" {
  name                = "tfex-cosmos-mongo-db"
  resource_group_name = azurerm_cosmosdb_account.db_account.resource_group_name
  account_name        = azurerm_cosmosdb_account.db_account.name
  throughput          = 400
}

resource "null_resource" "create_env_file" {
  triggers = {
    cosmos_db_connection_string_base64 = base64encode(azurerm_cosmosdb_account.db_account.connection_strings[0])
  }

  provisioner "local-exec" {
    command = <<EOF
        sed -i "s/database_url: secret/database_url: ${base64encode(azurerm_cosmosdb_account.db_account.connection_strings[0])}/g" ../k8s/secrets/backend-secrets.yaml
        sed -i "s/database_url: secret/database_url: ${base64encode(azurerm_cosmosdb_account.db_account.connection_strings[0])}/g" ../k8s/secrets/frontend-secrets.yaml
    EOF
    working_dir = path.module
    
  }
}