module "vpc" {
    source  = "terraform-google-modules/network/google"
    version = "~> 5.0"

    project_id   = var.gcp_project
    network_name = "vpc-test"
    routing_mode = "GLOBAL"

    subnets = [
        {
            subnet_name           = "subnet-01"
            subnet_ip             = "10.10.0.0/16"
            subnet_region         = var.region
        }
    ]

    secondary_ranges = {
        subnet-01 = [
            {
                range_name    = "gke-01-pods"
                ip_cidr_range = "10.100.0.0/16"
            },
            {
                range_name    = "gke-01-services"
                ip_cidr_range = "10.200.0.0/16"
            },
        ]

        subnet-02 = []
    }
}
