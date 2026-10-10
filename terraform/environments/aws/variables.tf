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
  default = "us-east-1"
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
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

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  description = "Par de llaves EC2 para SSH (opcional)."
  type        = string
  default     = null
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
  description = "Imagen que corre en cada VM y en Kubernetes."
  type        = string
  default     = "ghcr.io/thiagoicochea/ejerciciosemana09cloud:latest"
}

variable "enable_kubernetes" {
  type    = bool
  default = true
}

variable "k8s_node_count" {
  type    = number
  default = 3
}
