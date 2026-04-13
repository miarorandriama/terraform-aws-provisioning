module "vpc" {
  source = "./modules/vpc"
  env = "dev"
  # You can override the module's default variables by specifying them here or adding them to the main variables.tf file
  # vpc_cidr = "20.0.0.0/16"
  # public_subnet_cidr = "20.0.1.0/24"
  # private_subnet_cidr = "20.0.2.0/24"
  # az = "us-east-1a"
}

module "ec2" {
  source = "./modules/ec2"
  # You can override the module's default variables by specifying them here or adding them to the main variables.tf file
  # instance_name = "my_ec2_instance"
  # instance_type = "t2.medium"
  # env = "test"

  vpc_id = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnet_id
}