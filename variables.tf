# VPC Configuration variables
variable "vpc_config" {
  description = "Common value for the VPC configuration"
  type        = map(string)
}

# EC2 Instance Configuration variables
variable "instance_config" {
  description = "Configuration for the EC2 instance"
  type        = map(string)
  default = {}
}

# S3 Bucket Configuration variables
variable "ec2_bucket_config" {
  description = "Configuration for the S3 bucket linked to the EC2 instance"
  type        = map(string)
  default = {}
}

variable "tfstate_bucket_config" {
  description = "Configuration for the Terraform backend bucket"
  type = map(string)
  default = {}
}

# Tags and environment variables
variable "environment" {
  description = "Name of the environment"
  type        = string
  default = "dev"
}

variable "common_tags" {
  description = "Common tags for all the resources"
  type        = map(string)
}

variable "instance_tags" {
  description = "Additional tags specific for the EC2 instance"
  type        = map(string)
  default     = {}
}

variable "ec2_bucket_tags" {
  description = "Additional tags specific for the S3 bucket associated to the EC2 instance"
  type        = map(string)
  default     = {}
}

variable "tfstate_bucket_tags" {
  description = "Additional tags specific for the Terraform backend bucket"
  type        = map(string)
  default     = {}
}
