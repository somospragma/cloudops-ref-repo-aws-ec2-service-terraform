###################################################
# Outputs del ejemplo
###################################################

output "instance_ids" {
  description = "IDs de las instancias EC2 creadas"
  value       = module.ec2.instance_ids
}

output "instance_private_ips" {
  description = "IPs privadas de las instancias EC2"
  value       = module.ec2.instance_private_ips
}

output "instance_public_ips" {
  description = "IPs públicas de las instancias EC2 (si están habilitadas)"
  value       = module.ec2.instance_public_ips
}

output "elastic_ips" {
  description = "IPs elásticas asignadas a las instancias EC2"
  value       = module.ec2.elastic_ips
}
