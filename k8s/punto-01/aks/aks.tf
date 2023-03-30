# az aks get-versions --location eastus --output table

module "aks" {
  source  = "Azure/aks/azurerm"
  version = "~>4.0"

  resource_group_name              = azurerm_resource_group.this.name //  Grupo de recursos en Azure
  kubernetes_version               = "1.23.15"                        // Versión de kubernetes
  orchestrator_version             = "1.23.15"
  prefix                           = "translago"
  cluster_name                     = "translago"                        // Nombre del cluster
  vnet_subnet_id                   = module.network.vnet_subnets[0] // Red
  os_disk_size_gb                  = 30
  sku_tier                         = "Free" # defaults to Free, maybe Paid
  network_plugin                   = "kubenet"
  net_profile_pod_cidr             = "192.168.0.0/21" // Permite dar una Ip a los Pods de Kubernetes
  enable_role_based_access_control = false
  private_cluster_enabled          = false
  enable_http_application_routing  = true
  enable_azure_policy              = true
  enable_auto_scaling              = false
  network_policy                   = null # "calico" #null
  agents_min_count                 = 1    // Crea un node group
  agents_max_count                 = 4
  agents_count                     = 1  # Please set `agents_count` `null` while `enable_auto_scaling` is `true` to avoid possible `agents_count` changes.
  agents_max_pods                  = 30 // Máxima cantidad de pods
  agents_pool_name                 = "system"
  agents_size                      = "Standard_A2_v2" // Tipo de maquina
  agents_availability_zones        = ["1", "2"]
  enable_log_analytics_workspace   = true // Activar o desactivar logs para monitoreo.

  agents_labels = {
    "node" : "system"
  }

  enable_ingress_application_gateway      = true
  ingress_application_gateway_name        = "aks-agw"
  ingress_application_gateway_subnet_cidr = "10.52.0.0/24"

  depends_on = [module.network]
}

module "aks-node-pool" {
  source  = "guidalabs/aks-node-pool/azure"
  version = "0.1.6"

  resource_group_name   = azurerm_resource_group.this.name
  orchestrator_version  = "1.23.15"
  location              = var.region
  vnet_subnet_id        = module.network.vnet_subnets[0]
  kubernetes_cluster_id = module.aks.aks_id

  node_pools = {
    workloads = {
      vm_size               = "Standard_A2_v2"
      enable_auto_scaling   = false
      os_disk_size_gb       = 30
      os_disk_type          = "Managed"
      node_count            = 1
      min_count             = null
      max_count             = null
      availability_zones    = ["1", "2"]
      enable_node_public_ip = false # if set to true node_public_ip_prefix_id is required
      # node_public_ip_prefix_id = module.public-ip-prefix.prefix_id[0]
      node_labels = { "node" = "workload" }
      # node_taints              = ["workload=example:NoSchedule"]
      max_pods    = 50
      agents_tags = {}
    }
  }
}

resource "local_sensitive_file" "kubeconfig" {
  filename = "./kubeconfig"
  content  = module.aks.kube_config_raw
}

output "api_aks" {
  value = module.aks.host
}