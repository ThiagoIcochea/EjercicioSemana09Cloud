variable "name" {
  type = string
}

variable "vm_groups" {
  type = map(number)
}

variable "container_image" {
  type = string
}

variable "host_port_base" {
  type    = number
  default = 18000
}
