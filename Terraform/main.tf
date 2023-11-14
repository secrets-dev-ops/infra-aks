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

resource "azurerm_subnet" "subnet" {
  name                 = "subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]  
}

resource "azurerm_public_ip" "public_ip" {
  name                = "public-ip"
  resource_group_name = var.resource_group_nameSS
  location            = var.region
  allocation_method   = "Static"
  sku                 = "Standard" 

}

locals {
    backend_address_pool_name      = "${azurerm_virtual_network.main.name}-beap"
    frontend_port_name             = "${azurerm_virtual_network.main.name}-feport"
    frontend_ip_configuration_name = "${azurerm_virtual_network.main.name}-feip"
    http_setting_name              = "${azurerm_virtual_network.main.name}-be-htst"
    listener_name                  = "${azurerm_virtual_network.main.name}-httplstn"
    request_routing_rule_name      = "${azurerm_virtual_network.main.name}-rqrt"
    redirect_configuration_name    = "${azurerm_virtual_network.main.name}-rdrcfg"
  }

resource "azurerm_application_gateway" "network" {
  name                = "appgateway"
  resource_group_name = var.resource_group_name
  location            = var.region

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.subnet.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 8081
    protocol              = "Http"
    request_timeout       = 60
  }

  backend_http_settings {
    name                  = "sonar-http-settings"
    cookie_based_affinity = "Disabled"
    path                  = "/sonar"
    port                  = 9000 
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
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

resource "azurerm_role_assignment" "role_acrpull" {
  scope                            = var.acr_id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.twitter-aks.kubelet_identity.0.object_id
  skip_service_principal_aad_check = true
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

resource "null_resource" "set_cosmos_db_connection_string" {
  triggers = {
    cosmos_db_connection_string_base64 = base64encode(azurerm_cosmosdb_account.db_account.connection_strings[0])
  }

  provisioner "local-exec" {
    command = "echo ${base64encode(azurerm_cosmosdb_account.db_account.connection_strings[0])} > ../string-connection-encoded.txt"
    working_dir = "${path.module}"

  }
}