###################################################
# EC2 Instance Resources
###################################################

resource "aws_instance" "this" {
  provider = aws.project
  
  for_each = {
    for k, v in var.instances_config : k => v
    if lookup(v, "enabled", true)
  }
  
  ami                    = each.value.ami
  instance_type          = each.value.instance_type
  subnet_id              = each.value.subnet_id
  vpc_security_group_ids = each.value.security.security_group_ids
  key_name               = lookup(each.value.security, "key_name", null)
  
  iam_instance_profile = lookup(each.value, "iam_instance_profile", null)
  
  # Configuración de metadatos IMDSv2 por defecto
  metadata_options {
    http_endpoint               = lookup(each.value, "metadata_http_endpoint", "enabled")
    http_tokens                 = lookup(each.value, "metadata_http_tokens", "required")
    http_put_response_hop_limit = lookup(each.value, "metadata_http_put_response_hop_limit", 1)
    instance_metadata_tags      = lookup(each.value, "metadata_instance_metadata_tags", "enabled")
  }
  
  # Configuración de monitoreo detallado
  monitoring = lookup(each.value, "detailed_monitoring", false)
  
  # Configuración de IP pública
  associate_public_ip_address = lookup(each.value, "associate_public_ip_address", false)
  
  # Configuración del dispositivo raíz
  dynamic "root_block_device" {
    for_each = each.value.root_block_device != null ? [each.value.root_block_device] : []
    
    content {
      volume_type           = lookup(root_block_device.value, "volume_type", "gp3")
      volume_size           = lookup(root_block_device.value, "volume_size", 20)
      encrypted             = lookup(root_block_device.value, "encrypted", true)
      kms_key_id            = lookup(root_block_device.value, "kms_key_id", null)
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", true)
      tags = merge(
        {
          Name = "${var.client}-${var.project}-${var.environment}-ebs-${each.key}-root"
        },
        each.value.additional_tags
      )
    }
  }
  
  # Configuración de volúmenes EBS adicionales
  dynamic "ebs_block_device" {
    for_each = lookup(each.value, "ebs_block_devices", {})
    
    content {
      device_name           = ebs_block_device.key
      volume_type           = lookup(ebs_block_device.value, "volume_type", "gp3")
      volume_size           = lookup(ebs_block_device.value, "volume_size", 20)
      encrypted             = lookup(ebs_block_device.value, "encrypted", true)
      kms_key_id            = lookup(ebs_block_device.value, "kms_key_id", null)
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", true)
      tags = merge(
        {
          Name = "${var.client}-${var.project}-${var.environment}-ebs-${each.key}-${replace(ebs_block_device.key, "/", "-")}"
        },
        each.value.additional_tags
      )
    }
  }
  
  # Configuración de interfaces de red
  dynamic "network_interface" {
    for_each = lookup(each.value, "network_interfaces", {})
    
    content {
      device_index          = network_interface.value.device_index
      network_interface_id  = lookup(network_interface.value, "network_interface_id", null)
      delete_on_termination = lookup(network_interface.value, "delete_on_termination", false)
    }
  }
  
  # Configuración de datos de usuario
  user_data = lookup(each.value, "user_data", null)
  
  # Etiquetas
  tags = merge(
    {
      Name = local.instance_names[each.key]
    },
    each.value.additional_tags
  )
}

###################################################
# EBS Volumes (adicionales, separados de la instancia)
###################################################

resource "aws_ebs_volume" "this" {
  provider = aws.project
  
  for_each = {
    for item in local.additional_ebs_volumes : "${item.instance_key}.${item.volume_key}" => item
  }
  
  availability_zone = aws_instance.this[each.value.instance_key].availability_zone
  size              = each.value.config.size
  type              = lookup(each.value.config, "type", "gp3")
  encrypted         = lookup(each.value.config, "encrypted", true)
  kms_key_id        = lookup(each.value.config, "kms_key_id", null)
  
  tags = merge(
    {
      Name = "${var.client}-${var.project}-${var.environment}-ebs-${each.value.instance_key}-${each.value.volume_key}"
    },
    var.instances_config[each.value.instance_key].additional_tags
  )
}

###################################################
# Volume Attachments
###################################################

resource "aws_volume_attachment" "this" {
  provider = aws.project
  
  for_each = {
    for item in local.additional_ebs_volumes : "${item.instance_key}.${item.volume_key}" => item
  }
  
  device_name = each.value.device_name
  volume_id   = aws_ebs_volume.this["${each.value.instance_key}.${each.value.volume_key}"].id
  instance_id = aws_instance.this[each.value.instance_key].id
}

###################################################
# Elastic IP (opcional)
###################################################

resource "aws_eip" "this" {
  provider = aws.project
  
  for_each = {
    for k, v in var.instances_config : k => v
    if lookup(v, "enabled", true) && lookup(v, "create_elastic_ip", false)
  }
  
  domain  = "vpc"
  tags = merge(
    {
      Name = local.eip_names[each.key]
    },
    each.value.additional_tags
  )
}

resource "aws_eip_association" "this" {
  provider = aws.project
  
  for_each = {
    for k, v in var.instances_config : k => v
    if lookup(v, "enabled", true) && lookup(v, "create_elastic_ip", false)
  }
  
  instance_id   = aws_instance.this[each.key].id
  allocation_id = aws_eip.this[each.key].id
}
