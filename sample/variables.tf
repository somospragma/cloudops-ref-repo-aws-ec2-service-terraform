###################################################
# Variables para el ejemplo
###################################################

variable "region" {
  description = "Región de AWS donde se desplegarán los recursos"
  type        = string
  default     = "us-east-1"
}

variable "client" {
  description = "Cliente al que pertenece el recurso"
  type        = string
  default     = "acme"
}

variable "project" {
  description = "Nombre del proyecto"
  type        = string
  default     = "webapp"
}

variable "environment" {
  description = "Entorno (dev, qa, pdn)"
  type        = string
  default     = "dev"
}

variable "ami_id" {
  description = "ID del AMI a utilizar para las instancias EC2"
  type        = string
  default     = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI (ejemplo)
}

variable "key_name" {
  description = "Nombre del par de claves para acceso SSH"
  type        = string
  default     = "my-key"
}


variable "subnet_id" {
  description = "ID de la subred para el servidor de aplicación"
  type        = string
}

variable "profile" {
  description = "Profile AWS"
  type = string
}