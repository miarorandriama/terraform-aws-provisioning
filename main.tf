module "vpc" {
  source = "./modules/vpc"

  vpc_cidr            = var.vpc_config.cidr_block
  public_subnet_cidr  = var.vpc_config.public_subnet_cidr
  private_subnet_cidr = var.vpc_config.private_subnet_cidr
  availability_zone   = var.vpc_config.availability_zone

  common_tags = var.common_tags
  environment         = var.environment
}

module "ec2" {
  source = "./modules/ec2"

  instance_name = var.instance_config.instance_name
  instance_type = var.instance_config.instance_type
  ami           = var.instance_config.ami

  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnet_id

  common_tags = var.common_tags
  environment         = var.environment
}