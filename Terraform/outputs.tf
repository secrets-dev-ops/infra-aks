output "resource_group_name" {
  value = var.resource_group_name
}

output "cluster_id" {
  value = azurerm_kubernetes_cluster.main.id
}

output "aks_cluster_fqdn" {
  value = azurerm_kubernetes_cluster.main.fqdn
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive = true
}

output "cosmosdb_account_name" {
  value = azurerm_cosmosdb_account.db_account.name
}

output "cosmosdb_account_endpoint" {
  value = azurerm_cosmosdb_account.db_account.endpoint
}