variable "instance_name" {
  description = "The name of the EC2 instance"
  type = string
  default = "the_ec2_instance"
}

variable "instance_type" {
  description = "The type of the EC2 instance"
  type = string
  default = "t2.micro"
}

variable "ami" {
  description = "The ami of the EC2 instance"
  type = string
  default = "ami-0fb653ca2d3203ac1" // Amazon Linux 2 AMI
}

variable "vpc_id" {
  description = "The ID of the VPC" // From the VPC module
  type = string
}

variable "subnet_id" {
  description = "The ID of the subnet" // From the VPC module
  type = string
}

variable "env" {
  description = "The environment for the EC2 instance"
  type = string
  default = "dev"
}

variable "common_tags" {
  description = "Common tags for all the ressources"
  type = map(string)
}