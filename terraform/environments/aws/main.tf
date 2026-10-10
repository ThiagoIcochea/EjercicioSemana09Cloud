terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70"
    }
  }

  # Para trabajo en equipo, descomentar y usar un bucket S3 propio:
  # backend "s3" {
  #   bucket = "mi-bucket-tfstate"
  #   key    = "semana09/aws/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = local.tags
  }
}

locals {
  tags = {
    project     = var.project
    environment = var.environment
    managed_by  = "terraform"
  }
}

module "network" {
  source = "../../modules/aws-network"

  name               = "${var.project}-${var.environment}"
  availability_zones = var.availability_zones
  ssh_allowed_cidrs  = var.ssh_allowed_cidrs
  app_port           = var.app_port
  tags               = local.tags
}

# 32 máquinas virtuales (por defecto 8 web + 8 api + 8 worker + 8 data).
module "vm_fleet" {
  source = "../../modules/aws-vm-fleet"

  name                  = "${var.project}-${var.environment}"
  vm_groups             = var.vm_groups
  subnet_ids            = module.network.subnet_ids
  security_group_id     = module.network.security_group_id
  default_instance_type = var.instance_type
  key_name              = var.key_name
  app_port              = var.app_port
  container_image       = var.container_image
  tags                  = local.tags
}

module "kubernetes" {
  source = "../../modules/aws-eks"
  count  = var.enable_kubernetes ? 1 : 0

  name       = "${var.project}-${var.environment}"
  subnet_ids = module.network.subnet_ids
  node_count = var.k8s_node_count
  tags       = local.tags
}
