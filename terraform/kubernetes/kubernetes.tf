data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

module "gke" {
  source                            = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  version                           = "~> 21.1"

  project_id                        = var.gcp_project
  name                              = "cluster-test-1"
  regional                          = true

  release_channel                   = "STABLE"
  region                            = var.region
  network                           = "vpc-test"
  subnetwork                        = "subnet-01"
  ip_range_pods                     = "gke-01-pods"
  ip_range_services                 = "gke-01-services"
  master_ipv4_cidr_block            = "172.16.0.16/28"

  service_account                   = "create"

  add_master_webhook_firewall_rules = true
  add_cluster_firewall_rules        = false
  add_shadow_firewall_rules         = false
  firewall_priority                 = 1000

  http_load_balancing               = false
  network_policy                    = false
  horizontal_pod_autoscaling        = true
  enable_vertical_pod_autoscaling   = false
  remove_default_node_pool          = true
  create_service_account            = true
  filestore_csi_driver              = true
  enable_shielded_nodes             = true

  enable_private_nodes              = true
  enable_private_endpoint           = false

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

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/trace.append",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/servicecontrol",
    ]
  }
  node_pools_tags = {
    all       = ["internal", "k8s"]
  }
}