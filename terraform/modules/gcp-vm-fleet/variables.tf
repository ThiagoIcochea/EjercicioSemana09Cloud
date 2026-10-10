variable "name" {
  type = string
}

variable "vm_groups" {
  description = "Cantidad de VMs por rol."
  type        = map(number)
}

variable "zones" {
  type = list(string)
}

variable "subnet_id" {
  type = string
}

variable "image" {
  type    = string
  default = "ubuntu-os-cloud/ubuntu-2204-lts"
}

variable "default_machine_type" {
  type    = string
  default = "e2-micro"
}

variable "machine_types" {
  type    = map(string)
  default = {}
}

variable "app_port" {
  type    = number
  default = 8080
}

variable "container_image" {
  type = string
}

variable "labels" {
  type    = map(string)
  default = {}
}
