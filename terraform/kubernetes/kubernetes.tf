data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

module "gke" {
  source                            = "terraform-google-modules/kubernetes-engine/google"
  version                           = "~> 21.1"

  project_id                        = var.gcp_project
  name                              = "cluster-test-1"
  release_channel                   = "STABLE"
  region                            = var.region
  network                           = "default"
  subnetwork                        = "default"
  ip_range_pods                     = "gke-01-pods"
  ip_range_services                 = "gke-01-services"

  add_master_webhook_firewall_rules = true
  http_load_balancing               = false
  network_policy                    = false
  horizontal_pod_autoscaling        = true
  enable_vertical_pod_autoscaling   = false
  create_service_account            = false
  filestore_csi_driver              = true
  enable_shielded_nodes             = true

  master_authorized_networks = [
    {
      cidr_block   = var.authorized_cidr_block
      display_name = "MyIP"
    },
  ]

  node_pools =[
    {
      name               = "pool-1"
      machine_type       = "n1-standard-1"
      disk_size_gb       = 100
      preemptible        = false
      autoscaling        = true
      initial_node_count = 1
      max_count          = 12
      min_count          = 1
      enable_secure_boot = true
    }
  ]

  node_pools_tags = {
    all       = ["internal", "k8s"]
  }
}