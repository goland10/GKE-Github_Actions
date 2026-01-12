data "google_compute_zones" "this" {
  region = var.region
}

resource "random_shuffle" "zone" {
  input        = data.google_compute_zones.this.names
  result_count = 1

  keepers = {
    region = var.region
  }
}

locals {
  all_zones = data.google_compute_zones.this.names

  node_locations = (
    var.environment == "dev" ?
    random_shuffle.zone.result :

    var.environment == "staging" ?
    slice(local.all_zones, 0, 2) :

    local.all_zones
  )
}

locals {
  impersonate_sa = "github-terraform"
}

module "network" {
  source = "./modules/network"
  region = var.region
}

module "iam" {
  source     = "./modules/iam"
  account_id = "${local.impersonate_sa}@${var.project_id}.iam.gserviceaccount.com"
}

module "gke" {
  source = "./modules/gke"

  project_id     = var.project_id
  environment    = var.environment
  region         = var.region
  node_locations = local.node_locations

  #cluster_name = local.full_cluster_name
  cluster_name = var.cluster_name

  network             = module.network.vpc_id
  subnetwork          = module.network.subnet_id
  pods_range_name     = "pods"
  services_range_name = "services"

  machine_type = var.machine_type
  disk_size_gb = var.disk_size_gb
  node_min     = var.node_min
  node_max     = var.node_max
  node_count   = var.node_count

  deletion_protection = var.deletion_protection
  service_account     = module.iam.nodes_SA-email

  release_channel       = var.release_channel
  logging_components    = var.logging_components
  monitoring_components = var.monitoring_components
}
