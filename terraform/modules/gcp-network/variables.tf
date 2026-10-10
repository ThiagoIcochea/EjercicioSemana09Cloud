variable "name" {
  type = string
}

variable "region" {
  type = string
}

variable "subnet_cidr" {
  type    = string
  default = "10.30.0.0/20"
}

variable "pods_cidr" {
  type    = string
  default = "10.40.0.0/14"
}

variable "services_cidr" {
  type    = string
  default = "10.44.0.0/20"
}

variable "ssh_allowed_cidrs" {
  type    = list(string)
  default = []
}

variable "app_port" {
  type    = number
  default = 8080
}
