###################################################
# Ejemplo de uso del módulo EC2
###################################################

provider "aws" {
  region = var.region
  alias  = "principal"
  profile = var.profile
  
  default_tags {
    tags = {
      Client      = var.client
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

###################################################
# Provider Configuration
###################################################

terraform {
  required_version = ">= 1.11.4"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}
