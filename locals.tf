###################################################
# Variables Locales
###################################################

locals {
  # Generar nombres de recursos siguiendo la convención de nomenclatura estándar
  instance_names = {
    for k, v in var.instances_config : k => "${var.client}-${var.project}-${var.environment}-ec2-${k}"
  }

  eip_names = {
    for k, v in var.instances_config : k => "${var.client}-${var.project}-${var.environment}-eip-${k}"
    if lookup(v, "enabled", true) && lookup(v, "create_elastic_ip", false)
  }

  # Procesamiento de volúmenes EBS adicionales
  additional_ebs_volumes = flatten([
    for instance_key, instance_config in var.instances_config : [
      for volume_key, volume_config in lookup(instance_config, "additional_volumes", {}) : {
        instance_key = instance_key
        volume_key   = volume_key
        device_name  = volume_config.device_name
        config = {
          size       = volume_config.size
          type       = lookup(volume_config, "type", "gp3")
          encrypted  = lookup(volume_config, "encrypted", true)
          kms_key_id = lookup(volume_config, "kms_key_id", null)
        }
      }
      if lookup(instance_config, "enabled", true)
    ]
  ])
}
