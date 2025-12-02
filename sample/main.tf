###################################################
# Módulo EC2
###################################################

module "ec2" {
  source = "../"
  
  providers = {
    aws.project = aws.principal
  }
  
  client      = var.client
  project     = var.project
  environment = var.environment
  
  instances_config = {
    # Servidor de aplicación
    app_server = {
      ami           = var.ami_id
      instance_type = "t3.micro"
      subnet_id     = var.subnet_id
      
      security = {
        security_group_ids = ["sg-0933c4b6b3619169a"]
        key_name           = var.key_name
      }
      
      root_block_device = {
        volume_size = 30
        volume_type = "gp3"
        encrypted   = true
      }
      
      additional_volumes = {
        data = {
          device_name = "/dev/sdf"
          size        = 50
          type        = "gp3"
          encrypted   = true
        }
      }
      
      associate_public_ip_address = true
      create_elastic_ip           = true
      
      user_data = <<-EOF
        #!/bin/bash
        echo "Instalando dependencias..."
        yum update -y
        yum install -y httpd
        systemctl start httpd
        systemctl enable httpd
        echo "Configuración completada" > /var/www/html/index.html
      EOF
      
      additional_tags = {
        Application = "WebApp"
        Role        = "AppServer"
      }
    }

  }
}
