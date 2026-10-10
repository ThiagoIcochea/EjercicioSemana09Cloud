variable "name" {
  type = string
}

variable "vm_groups" {
  description = "Cantidad de VMs por rol."
  type        = map(number)
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "ami_id" {
  description = "AMI fija opcional; si es null se usa Ubuntu 22.04 de Canonical."
  type        = string
  default     = null
}

variable "default_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "instance_types" {
  description = "Tipo de instancia por rol (sobrescribe el valor por defecto)."
  type        = map(string)
  default     = {}
}

variable "key_name" {
  type    = string
  default = null
}

variable "app_port" {
  type    = number
  default = 8080
}

variable "container_image" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
