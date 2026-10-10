terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.8"
    }
  }
}

locals {
  vms = merge([
    for role, count in var.vm_groups : {
      for i in range(count) : format("%s-%02d", role, i + 1) => {
        role  = role
        index = i
      }
    }
  ]...)
}

resource "google_compute_instance" "vm" {
  for_each = local.vms

  name         = "${var.name}-${each.key}"
  machine_type = lookup(var.machine_types, each.value.role, var.default_machine_type)
  # Reparte las VMs entre las zonas de la región.
  zone = var.zones[each.value.index % length(var.zones)]
  tags = [var.name, each.value.role]

  boot_disk {
    initialize_params {
      image = var.image
      size  = 20
    }
  }

  network_interface {
    subnetwork = var.subnet_id
    access_config {}
  }

  metadata_startup_script = templatefile("${path.module}/../../templates/cloud-init.sh.tftpl", {
    cloud           = "gcp"
    vm_name         = "${var.name}-${each.key}"
    vm_role         = each.value.role
    app_port        = var.app_port
    container_image = var.container_image
  })

  labels = merge(var.labels, { role = each.value.role })
}
