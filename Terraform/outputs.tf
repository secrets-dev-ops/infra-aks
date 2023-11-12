output "resource_group_name" {
  value = var.resource_group_name
}

output "cluster_id" {
  value = azurerm_kubernetes_cluster.twitter-aks.id
}

output "aks_cluster_fqdn" {
  value = azurerm_kubernetes_cluster.twitter-aks.fqdn
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.twitter-aks.kube_config_raw
  sensitive = true
}

output "cosmosdb_account_name" {
  value = azurerm_cosmosdb_account.db_account.name
}

output "cosmosdb_account_endpoint" {
  value = azurerm_cosmosdb_account.db_account.endpoint
}

output "cosmos_db_connection_string" {
  value = base64encode(azurerm_cosmosdb_account.db_account.connection_strings[0])
  sensitive = true
}