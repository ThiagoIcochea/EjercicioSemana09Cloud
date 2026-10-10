terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.8"
    }
  }
}

resource "google_container_cluster" "this" {
  name     = var.name
  location = var.region

  network    = var.network_name
  subnetwork = var.subnet_name

  # Se gestiona el node pool por separado.
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  release_channel {
    channel = "REGULAR"
  }
}

resource "google_container_node_pool" "default" {
  name     = "${var.name}-default"
  cluster  = google_container_cluster.this.id
  location = var.region

  node_count = var.node_count_per_zone

  autoscaling {
    min_node_count = var.node_min_per_zone
    max_node_count = var.node_max_per_zone
  }

  node_config {
    machine_type = var.node_machine_type
    disk_size_gb = 30
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    labels       = var.labels
  }
}
