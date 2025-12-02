# Módulo Terraform: terraform-aws-ec2-module

## Descripción
Este módulo permite la creación y gestión de instancias EC2 en AWS siguiendo las mejores prácticas de seguridad y configuración. Proporciona una forma estandarizada de desplegar instancias EC2 con configuraciones personalizables.

## Requisitos
- Terraform >= 1.11.4
- AWS Provider >= 5.0.0

## Diagrama de Arquitectura
```
┌─────────────────────────┐
│                         │
│  ┌─────────────────┐    │
│  │  EC2 Instance   │    │
│  │                 │    │
│  │  ┌───────────┐  │    │
│  │  │  EBS Vol  │  │    │
│  │  └───────────┘  │    │
│  │                 │    │
│  └─────────────────┘    │
│                         │
└─────────────────────────┘
```

## Recursos Creados
- Instancias EC2 (aws_instance)
- Volúmenes EBS adicionales (aws_ebs_volume)
- Asociaciones de volúmenes (aws_volume_attachment)
- Interfaces de red elásticas (opcional)
- Direcciones IP elásticas (opcional)

## Configuración de Providers
Este módulo requiere que se le pase un provider AWS con el alias `project`. Ejemplo:

```hcl
provider "aws" {
  region = "us-east-1"
  alias  = "principal"
  
  # Configuración adicional...
}

module "ec2" {
  source = "ruta/al/modulo"
  
  providers = {
    aws.project = aws.principal
  }
  
  # Resto de la configuración...
}
```

## Uso Básico
```hcl
module "ec2" {
  source = "ruta/al/modulo"
  
  providers = {
    aws.project = aws.principal
  }
  
  client      = "cliente"
  project     = "proyecto"
  environment = "dev"
  
  instances_config = {
    app_server = {
      ami           = "ami-0c55b159cbfafe1f0"
      instance_type = "t3.micro"
      subnet_id     = "subnet-123456"
      
      security = {
        security_group_ids = ["sg-123456"]
        key_name           = "my-key"
      }
      
      root_block_device = {
        volume_size = 20
        volume_type = "gp3"
        encrypted   = true
      }
      
      additional_tags = {
        Application = "WebApp"
        Role        = "AppServer"
      }
    }
  }
}
```

## Variables de Entrada
| Nombre | Descripción | Tipo | Valor por defecto | Requerido |
|--------|-------------|------|------------------|:---------:|
| client | Cliente al que pertenece el recurso | `string` | n/a | sí |
| project | Nombre del proyecto | `string` | n/a | sí |
| environment | Entorno (dev, qa, pdn) | `string` | n/a | sí |
| instances_config | Configuración de instancias EC2 | `map(object)` | `{}` | sí |

## Outputs
| Nombre | Descripción |
|--------|-------------|
| instance_ids | IDs de las instancias EC2 creadas |
| instance_arns | ARNs de las instancias EC2 creadas |
| instance_private_ips | IPs privadas de las instancias EC2 |
| instance_public_ips | IPs públicas de las instancias EC2 (si están habilitadas) |

## Seguridad
Este módulo implementa las mejores prácticas de seguridad para instancias EC2:
- Cifrado de volúmenes EBS por defecto
- Configuración de grupos de seguridad restrictivos
- Desactivación de IP pública por defecto
- Soporte para roles IAM con privilegios mínimos
- Configuración de monitoreo detallado
- Implementación de IMDSv2 por defecto

## Ejemplos
Ver directorio `sample/` para ejemplos completos.
