resource "aws_vpc" "the_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  tags = merge(
    var.common_tags,
    {
      Name = "The-${var.environment}-vpc"
    }
  )
}

// Private Subnet
resource "aws_subnet" "the_private_subnet" {
  vpc_id     = aws_vpc.the_vpc.id
  availability_zone = var.availability_zone
  cidr_block = var.private_subnet_cidr
  map_public_ip_on_launch = false
  tags = merge(
    var.common_tags,
    {
      Name = "The-${var.environment}-private-subnet"
    }
  )
}

// Public Subnet
resource "aws_subnet" "the_public_subnet" {
  vpc_id     = aws_vpc.the_vpc.id
  availability_zone = var.availability_zone
  cidr_block = var.public_subnet_cidr
  map_public_ip_on_launch = true
  tags = merge(
    var.common_tags,
    {
      Name = "The-${var.environment}-public-subnet"
    }
  )
}

#Création d'une passerelle Internet
resource "aws_internet_gateway" "the_igw" {
  vpc_id = aws_vpc.the_vpc.id
}

#Configuration de la table de routage pour les sous-réseaux publiques
resource "aws_route_table" "the_route_table" {
  vpc_id = aws_vpc.the_vpc.id
  route {
    cidr_block = "0.0.0.0/0" # Tout autre trafic redirigé vers l'Internet Gateway
    gateway_id = aws_internet_gateway.the_igw.id
  }
}

#Association des tables de routage aux sous-réseaux correspondants
resource "aws_route_table_association" "the_route_table_association" {
  subnet_id      = aws_subnet.the_public_subnet.id
  route_table_id = aws_route_table.the_route_table.id
}