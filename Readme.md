# Terraform infraestructure 
1. az aks get-credentials --resource-group <nombre_del_grupo_de_recursos> --name <nombre_del_cluster_AKS>

 2. az aks update -n <aks_name> -g <resurce_group_name> --attach-acr <acrname>
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx
 4. kubectl apply -k .
kubectl --namespace frontend-ns get services



az aks enable-addons --addons http_application_routing --name twitter-aks --resource-group resource-group-twitter

