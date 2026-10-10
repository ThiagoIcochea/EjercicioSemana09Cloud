variable "name" {
  type    = string
  default = "semana09-local"
}

variable "vm_groups" {
  type = map(number)
  default = {
    web    = 8
    api    = 8
    worker = 8
    data   = 8
  }
}

variable "container_image" {
  description = "Imagen local construida con docker build (ver README)."
  type        = string
  default     = "semana09-app:local"
}

variable "host_port_base" {
  type    = number
  default = 18000
}
