
module "cloud-nat" {
  source         = "terraform-google-modules/cloud-nat/google"
  version        = "~> 2.2"
  project_id     = var.gcp_project
  region         = var.region

  name           = "cloud-nat-test"
  network        = module.vpc.network_name
  create_router  = true
  router        = "router-test"
}
