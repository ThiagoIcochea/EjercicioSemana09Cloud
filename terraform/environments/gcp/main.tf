# Autor: Thiago Paolo Icochea Rodriguez — Servicios Cloud, Sección 42905 (UTP)
# Desarrollado con apoyo de Claude (Anthropic), modelo Claude Opus 5.5.
terraform {
  required_version = ">= 1.7.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.8"
    }
  }

  # backend "gcs" {
  #   bucket = "mi-bucket-tfstate"
  #   prefix = "semana09/gcp"
  # }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  name = "${var.project}-${var.environment}"
  labels = {
    project     = var.project
    environment = var.environment
    managed_by  = "terraform"
  }
}

module "network" {
  source = "../../modules/gcp-network"

  name              = local.name
  region            = var.region
  ssh_allowed_cidrs = var.ssh_allowed_cidrs
  app_port          = var.app_port
}

# 32 máquinas virtuales repartidas entre las zonas de la región.
module "vm_fleet" {
  source = "../../modules/gcp-vm-fleet"

  name                 = local.name
  vm_groups            = var.vm_groups
  zones                = var.zones
  subnet_id            = module.network.subnet_id
  default_machine_type = var.machine_type
  app_port             = var.app_port
  container_image      = var.container_image
  labels               = local.labels
}

module "kubernetes" {
  source = "../../modules/gcp-gke"
  count  = var.enable_kubernetes ? 1 : 0

  name         = local.name
  region       = var.region
  network_name = module.network.network_name
  subnet_name  = module.network.subnet_name
  labels       = local.labels
}
