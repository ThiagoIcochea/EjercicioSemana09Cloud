variable "name" {
  description = "Prefijo de nombres de los recursos."
  type        = string
}

variable "vpc_cidr" {
  description = "Rango CIDR de la VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "availability_zones" {
  description = "Zonas de disponibilidad donde se crean subredes."
  type        = list(string)
}

variable "ssh_allowed_cidrs" {
  description = "CIDRs que pueden entrar por SSH."
  type        = list(string)
  default     = []
}

variable "app_port" {
  description = "Puerto en el que escucha el contenedor de la aplicación."
  type        = number
  default     = 8080
}

variable "tags" {
  description = "Etiquetas comunes."
  type        = map(string)
  default     = {}
}
