terraform {
  required_version = ">= 1.7.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# Usa el Docker local (o el del runner de GitHub Actions).
provider "docker" {}

# Réplica local de la flota: 32 contenedores con los mismos nombres y roles
# que las VMs de AWS/GCP. Sirve para probar el orquestador sin pagar nube.
module "vm_fleet" {
  source = "../../modules/docker-vm-fleet"

  name            = var.name
  vm_groups       = var.vm_groups
  container_image = var.container_image
  host_port_base  = var.host_port_base
}
