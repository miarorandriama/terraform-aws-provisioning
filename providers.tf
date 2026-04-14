terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
  access_key = "test"
  secret_key = "test"

  endpoints {
    ec2 = "http://localhost:4566"
  }

  skip_credentials_validation = true
  skip_metadata_api_check = true
  skip_requesting_account_id = true
}