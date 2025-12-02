###################################################
# Outputs de Instancias EC2
###################################################

output "instance_ids" {
  description = "IDs de las instancias EC2 creadas"
  value = {
    for k, v in aws_instance.this : k => v.id
  }
}

output "instance_arns" {
  description = "ARNs de las instancias EC2 creadas"
  value = {
    for k, v in aws_instance.this : k => v.arn
  }
}

output "instance_private_ips" {
  description = "IPs privadas de las instancias EC2"
  value = {
    for k, v in aws_instance.this : k => v.private_ip
  }
}

output "instance_public_ips" {
  description = "IPs públicas de las instancias EC2 (si están habilitadas)"
  value = {
    for k, v in aws_instance.this : k => v.public_ip if v.public_ip != null
  }
}

output "elastic_ips" {
  description = "IPs elásticas asignadas a las instancias EC2"
  value = {
    for k, v in aws_eip.this : k => v.public_ip
  }
}

###################################################
# Outputs de Volúmenes EBS
###################################################

output "root_volume_ids" {
  description = "IDs de los volúmenes raíz de las instancias EC2"
  value = {
    for k, v in aws_instance.this : k => v.root_block_device[0].volume_id
  }
}

output "additional_volume_ids" {
  description = "IDs de los volúmenes EBS adicionales"
  value = {
    for k, v in aws_ebs_volume.this : k => v.id
  }
}
