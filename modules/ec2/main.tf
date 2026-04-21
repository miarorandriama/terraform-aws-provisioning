resource "aws_security_group" "the_ec2_sg" {
  name        = "${var.instance_name}-sg"
  description = "Allow SSH, HTTP, and HTTPS traffic to the EC2 instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(
    var.common_tags,
    {
      Name = "${var.env}-sg"
    }
  )
}

resource "aws_instance" "the_ec2_instance" {
  ami = var.ami
  instance_type = var.instance_type
  subnet_id = var.subnet_id
  vpc_security_group_ids = [aws_security_group.the_ec2_sg.id]
  tags = merge(
    var.common_tags,
    {
      Name = "${var.env}-${var.instance_name}"
    }
  )
}