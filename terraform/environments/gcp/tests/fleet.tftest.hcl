# Prueba sin credenciales: el proveedor Google se reemplaza por un mock.

mock_provider "google" {}

variables {
  project_id = "proyecto-de-prueba"
}

run "plan_32_vms" {
  command = plan

  assert {
    condition     = length(module.vm_fleet.vm_names) == 32
    error_message = "Se esperaban 32 VMs en GCP."
  }

  assert {
    condition     = length(distinct([for vm in module.vm_fleet.vm_names : vm])) == 32
    error_message = "Los nombres de las VMs deben ser únicos."
  }

  assert {
    condition     = length(module.kubernetes) == 1
    error_message = "El clúster GKE debería estar habilitado."
  }
}

run "flota_personalizada" {
  command = plan

  variables {
    vm_groups = {
      web = 2
      api = 3
    }
    enable_kubernetes = false
  }

  assert {
    condition     = length(module.vm_fleet.vm_names) == 5
    error_message = "La flota debería respetar vm_groups."
  }
}
