
resource "azurerm_kubernetes_cluster" "test" {
  name                = "${var.aks_name}-aks"    
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  dns_prefix          = "${var.aks_dns_name}"
  kubernetes_version  = "${var.kubernetes_version}"

  default_node_pool {
    name            = "default"
    node_count      = "${var.cluster_size}"
    vm_size         = "${var.vm_size}"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = "${var.aks_sp_id}"
    client_secret = "${var.aks_sp_secret}"
  }

  tags = {
    Environment = "${var.environment}"
  }
}
