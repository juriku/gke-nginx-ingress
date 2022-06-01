resource "google_compute_address" "nginx_ingress_ip" {
  name         = "nginx-ingress-test-1"
  address_type = "EXTERNAL"
  description  = "IP address for nginx-ingress"
  region       = var.region
  project      = var.gcp_project
  lifecycle {
    ignore_changes = [description]
  }
}