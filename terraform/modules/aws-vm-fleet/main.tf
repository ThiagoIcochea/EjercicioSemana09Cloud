terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70"
    }
  }
}

locals {
  # Expande {web = 8, api = 8, ...} a un mapa con una entrada por VM:
  # "web-01" => { role = "web", index = 0 }, ...
  vms = merge([
    for role, count in var.vm_groups : {
      for i in range(count) : format("%s-%02d", role, i + 1) => {
        role  = role
        index = i
      }
    }
  ]...)
}

# AMI de Ubuntu 22.04 publicada por Canonical en SSM (sin depender de filtros de búsqueda).
data "aws_ssm_parameter" "ubuntu" {
  name = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

resource "aws_instance" "vm" {
  for_each = local.vms

  ami                    = var.ami_id != null ? var.ami_id : data.aws_ssm_parameter.ubuntu.value
  instance_type          = lookup(var.instance_types, each.value.role, var.default_instance_type)
  subnet_id              = var.subnet_ids[each.value.index % length(var.subnet_ids)]
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name

  user_data = templatefile("${path.module}/../../templates/cloud-init.sh.tftpl", {
    cloud           = "aws"
    vm_name         = "${var.name}-${each.key}"
    vm_role         = each.value.role
    app_port        = var.app_port
    container_image = var.container_image
  })

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = merge(var.tags, {
    Name = "${var.name}-${each.key}"
    Role = each.value.role
  })
}
