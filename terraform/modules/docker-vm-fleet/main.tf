terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
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

  # Puerto de host estable por VM: base + posición en orden alfabético.
  ordered = sort(keys(local.vms))
  ports   = { for i, k in local.ordered : k => var.host_port_base + i }
}

resource "docker_network" "fleet" {
  name = "${var.name}-net"
}

# Cada contenedor representa una "VM" de la flota (mismo rol, nombre y
# variables que recibirían las VMs reales en AWS/GCP).
resource "docker_container" "vm" {
  for_each = local.vms

  name  = "${var.name}-${each.key}"
  image = var.container_image

  env = [
    "CLOUD_PROVIDER=local-docker",
    "VM_NAME=${var.name}-${each.key}",
    "VM_ROLE=${each.value.role}",
  ]

  ports {
    internal = 8080
    external = local.ports[each.key]
  }

  networks_advanced {
    name    = docker_network.fleet.name
    aliases = [each.key]
  }

  labels {
    label = "fleet"
    value = var.name
  }

  labels {
    label = "role"
    value = each.value.role
  }

  memory  = 64
  restart = "unless-stopped"

  healthcheck {
    test     = ["CMD", "python", "-c", "import urllib.request;urllib.request.urlopen('http://127.0.0.1:8080/healthz')"]
    interval = "5s"
    timeout  = "3s"
    retries  = 5
  }
}
