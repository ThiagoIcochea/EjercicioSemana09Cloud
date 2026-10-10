variable "name" {
  type = string
}

variable "region" {
  type = string
}

variable "network_name" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "node_machine_type" {
  type    = string
  default = "e2-standard-2"
}

variable "node_count_per_zone" {
  type    = number
  default = 1
}

variable "node_min_per_zone" {
  type    = number
  default = 1
}

variable "node_max_per_zone" {
  type    = number
  default = 3
}

variable "labels" {
  type    = map(string)
  default = {}
}
