resource "aws_instance" "the_ec2_instance" {
  ami = var.ami
  instance_type = var.instance_type
  
  iam_instance_profile = aws_iam_instance_profile.the_ec2_profile.name

  subnet_id = var.subnet_id
  vpc_security_group_ids = [aws_security_group.the_ec2_sg.id]

  tags = merge(
    var.common_tags,
    var.additional_tags,
    {
      Name = "${var.instance_name}"
    }
  )
}

resource "aws_security_group" "the_ec2_sg" {
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
      Name = "${var.environment}-sg"
    }
  )
}

# Le Rôle IAM que l'EC2 va endosser
resource "aws_iam_role" "the_ec2_role" {
  name = "${var.instance_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

# Attachement d'une politique S3 (Accès Full pour tes tests S3)
resource "aws_iam_role_policy_attachment" "the_s3_access" {
  role       = aws_iam_role.the_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# L'Instance Profile (C'est lui qu'on donne à l'EC2)
resource "aws_iam_instance_profile" "the_ec2_profile" {
  name = "${var.instance_name}-profile"
  role = aws_iam_role.the_ec2_role.name
}