variable "project_id" {
  description = "ID del proyecto de GCP."
  type        = string
}

variable "project" {
  type    = string
  default = "semana09"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "zones" {
  type    = list(string)
  default = ["us-central1-a", "us-central1-b", "us-central1-c"]
}

variable "vm_groups" {
  description = "Cantidad de VMs por rol. La suma por defecto es 32."
  type        = map(number)
  default = {
    web    = 8
    api    = 8
    worker = 8
    data   = 8
  }

  validation {
    condition     = sum(values(var.vm_groups)) > 0 && alltrue([for n in values(var.vm_groups) : n >= 0 && floor(n) == n])
    error_message = "vm_groups debe contener enteros no negativos y al menos una VM."
  }
}

variable "machine_type" {
  type    = string
  default = "e2-micro"
}

variable "ssh_allowed_cidrs" {
  type    = list(string)
  default = []
}

variable "app_port" {
  type    = number
  default = 8080
}

variable "container_image" {
  type    = string
  default = "ghcr.io/thiagoicochea/ejerciciosemana09cloud:latest"
}

variable "enable_kubernetes" {
  type    = bool
  default = true
}
