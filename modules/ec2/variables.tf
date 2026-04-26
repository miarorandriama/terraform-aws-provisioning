variable "instance_name" {
  description = "The name of the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "The type of the EC2 instance"
  type        = string
}

variable "ami" {
  description = "The ami of the EC2 instance"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC" // From the VPC module
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet" // From the VPC module
  type        = string
}

variable "s3_bucket_arn" {
  description = "L'ARN du bucket S3 pour restreindre l'accès IAM"
  type        = string
  default     = "*" # Par sécurité, on peut mettre * mais l'idéal est de passer l'ARN
}

# Tags and environment variables
variable "environment" {
  description = "The environment for the EC2 instance"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all the ressources"
  type        = map(string)
}

variable "additional_tags" {
  description = "Additional tags specific for the EC2 instance"
  type        = map(string)
  default     = {}
}