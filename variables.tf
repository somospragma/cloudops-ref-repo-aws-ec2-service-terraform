###################################################
# Variables Generales
###################################################

variable "client" {
  description = "Cliente al que pertenece el recurso"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.client))
    error_message = "El nombre del cliente debe contener solo letras minúsculas, números y guiones."
  }
}

variable "project" {
  description = "Nombre del proyecto"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project))
    error_message = "El nombre del proyecto debe contener solo letras minúsculas, números y guiones."
  }
}

variable "environment" {
  description = "Entorno (dev, qa, pdn)"
  type        = string
  
  validation {
    condition     = contains(["dev", "qa", "pdn"], var.environment)
    error_message = "El entorno debe ser uno de: dev, qa, pdn."
  }
}

###################################################
# Variables de Configuración de Instancias
###################################################

variable "instances_config" {
  description = "Configuración de instancias EC2"
  type = map(object({
    # Configuración básica
    ami           = string
    instance_type = string
    subnet_id     = string
    enabled       = optional(bool, true)
    
    # Configuración de seguridad
    security = object({
      security_group_ids = list(string)
      key_name           = optional(string)
    })
    
    # Configuración de almacenamiento
    root_block_device = optional(object({
      volume_type           = optional(string, "gp3")
      volume_size           = optional(number, 20)
      encrypted             = optional(bool, true)
      kms_key_id            = optional(string)
      delete_on_termination = optional(bool, true)
    }))
    
    # Volúmenes EBS adicionales
    ebs_block_devices = optional(map(object({
      volume_type           = optional(string, "gp3")
      volume_size           = optional(number, 20)
      encrypted             = optional(bool, true)
      kms_key_id            = optional(string)
      delete_on_termination = optional(bool, true)
    })), {})
    
    # Volúmenes EBS adicionales (separados)
    additional_volumes = optional(map(object({
      device_name = string
      size        = number
      type        = optional(string, "gp3")
      encrypted   = optional(bool, true)
      kms_key_id  = optional(string)
    })), {})
    
    # Configuración de red
    associate_public_ip_address = optional(bool, false)
    create_elastic_ip           = optional(bool, false)
    network_interfaces = optional(map(object({
      device_index          = number
      network_interface_id  = optional(string)
      delete_on_termination = optional(bool, false)
    })), {})
    
    # Configuración de metadatos
    metadata_http_endpoint               = optional(string, "enabled")
    metadata_http_tokens                 = optional(string, "required")
    metadata_http_put_response_hop_limit = optional(number, 1)
    metadata_instance_metadata_tags      = optional(string, "enabled")
    
    # Configuración de monitoreo
    detailed_monitoring = optional(bool, false)
    
    # Configuración de IAM
    iam_instance_profile = optional(string)
    
    # Datos de usuario
    user_data = optional(string)
    
    # Etiquetas adicionales
    additional_tags = optional(map(string), {})
  }))
  
  default = {}
  
  validation {
    condition = alltrue([
      for k, v in var.instances_config : contains(["t2.micro", "t2.small", "t2.medium", "t3.micro", "t3.small", "t3.medium", "m5.large", "m5.xlarge", "c5.large", "c5.xlarge", "r5.large", "r5.xlarge"], v.instance_type)
    ])
    error_message = "El tipo de instancia debe ser uno de los tipos permitidos."
  }
  
  validation {
    condition = alltrue([
      for k, v in var.instances_config : v.ami != null && v.ami != ""
    ])
    error_message = "El AMI ID es obligatorio para todas las instancias."
  }
  
  validation {
    condition = alltrue([
      for k, v in var.instances_config : v.subnet_id != null && v.subnet_id != ""
    ])
    error_message = "El ID de subred es obligatorio para todas las instancias."
  }
  
  validation {
    condition = alltrue([
      for k, v in var.instances_config : length(v.security.security_group_ids) > 0
    ])
    error_message = "Al menos un grupo de seguridad debe ser especificado para cada instancia."
  }
}
