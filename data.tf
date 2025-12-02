###################################################
# Data Sources
###################################################

# Obtener información sobre la cuenta de AWS actual
data "aws_caller_identity" "current" {
  provider = aws.project
}

# Obtener información sobre la región de AWS actual
data "aws_region" "current" {
  provider = aws.project
}

# Obtener información sobre las zonas de disponibilidad en la región actual
data "aws_availability_zones" "available" {
  provider = aws.project
  state    = "available"
}
