terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.8"
    }
  }
}

resource "google_compute_network" "this" {
  name                    = "${var.name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "this" {
  name          = "${var.name}-subnet"
  region        = var.region
  network       = google_compute_network.this.id
  ip_cidr_range = var.subnet_cidr

  # Rangos secundarios para pods y servicios de GKE (VPC nativa).
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.pods_cidr
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.services_cidr
  }
}

resource "google_compute_firewall" "app" {
  name    = "${var.name}-allow-app"
  network = google_compute_network.this.name

  allow {
    protocol = "tcp"
    ports    = [tostring(var.app_port)]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = [var.name]
}

resource "google_compute_firewall" "ssh" {
  count = length(var.ssh_allowed_cidrs) > 0 ? 1 : 0

  name    = "${var.name}-allow-ssh"
  network = google_compute_network.this.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.ssh_allowed_cidrs
  target_tags   = [var.name]
}

resource "google_compute_firewall" "internal" {
  name    = "${var.name}-allow-internal"
  network = google_compute_network.this.name

  allow {
    protocol = "all"
  }

  source_ranges = [var.subnet_cidr]
}
