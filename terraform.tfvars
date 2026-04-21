environment = "local"

common_tags = {
  Project = "AWS Terraform"
  Owner   = "The Me"
  ManagedBy = "Terraform"
}

vpc_config = {
  cidr_block = "10.0.0.0/16"
  public_subnet_cidr = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
  availability_zone = "us-east-2a"
}

instance_config = {
  instance_name = "The_{{var.environment}}_EC2_Instance"
  instance_type = "t2.medium"
}