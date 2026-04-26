module "vpc" {
  source = "./modules/vpc"

  vpc_cidr            = var.vpc_config.cidr_block
  public_subnet_cidr  = var.vpc_config.public_subnet_cidr
  private_subnet_cidr = var.vpc_config.private_subnet_cidr
  availability_zone   = var.vpc_config.az

  environment         = var.environment
  common_tags = var.common_tags
}

module "ec2" {
  source = "./modules/ec2"

  instance_name = var.instance_config.instance_name
  instance_type = var.instance_config.instance_type
  ami           = var.instance_config.ami

  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnet_id

  s3_bucket_arn = module.app_data_bucket.the_bucket_arn # On lie les deux modules ici

  environment         = var.environment
  common_tags = var.common_tags
  additional_tags = var.instance_tags
}

# S3 Bucket linked to the EC2 instance for storing logs or data
module "app_data_bucket" {
  source = "./modules/s3"

  bucket_name = var.ec2_bucket_config.bucket_name
  versioning   = var.ec2_bucket_config.versioning

  environment = var.environment
  common_tags = var.common_tags
  additional_tags = var.ec2_bucket_tags
}

# S3 Bucket for Terraform backend (state file storage)
module "tf_state_bucket" {
  source = "./modules/s3"

  bucket_name = var.tfstate_bucket_config.bucket_name
  versioning   = var.tfstate_bucket_config.versioning

  environment = var.environment
  common_tags = var.common_tags
  additional_tags = var.tfstate_bucket_tags
}