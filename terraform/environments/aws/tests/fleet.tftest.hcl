# Prueba sin credenciales: el proveedor AWS se reemplaza por un mock y se
# verifica el plan (32 VMs, red y clúster EKS).

mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }

  mock_data "aws_ssm_parameter" {
    defaults = {
      value = "ami-0123456789abcdef0"
    }
  }
}

run "plan_32_vms" {
  command = plan

  assert {
    condition     = length(module.vm_fleet.vm_names) == 32
    error_message = "Se esperaban 32 VMs en AWS."
  }

  assert {
    condition     = length([for n in module.vm_fleet.vm_names : n if startswith(n, "web-")]) == 8
    error_message = "Se esperaban 8 VMs con rol web."
  }

  assert {
    condition     = length(module.kubernetes) == 1
    error_message = "El clúster EKS debería estar habilitado."
  }
}

run "kubernetes_opcional" {
  command = plan

  variables {
    enable_kubernetes = false
  }

  assert {
    condition     = length(module.kubernetes) == 0
    error_message = "EKS debería poder deshabilitarse."
  }
}
