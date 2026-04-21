variable "common_tags" {
  description = "Common tags for all the resources"
  type = map(string)
}

variable "environment" {
  description = "Name of the environment"
  type = string
}

variable "vpc_config" {
  description = "Common value for the VPC configuration"
  type = map(string)
}

variable "instance_config" {
  description = "Configuration for the EC2 instance"
  type = map(string)
  default = {
    instance_name = "my_ec2_instance"
    instance_type = "t2.medium"
    ami = "ami-0fb653ca2d3203ac1" // Amazon Linux 2 AMI
  }
}