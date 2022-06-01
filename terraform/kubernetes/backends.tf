terraform {
  backend "gcs" {
    prefix  = "terraform/kubernetes/state"
  }
}
