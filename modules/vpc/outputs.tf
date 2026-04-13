output "vpc_id" {
  value = aws_vpc.the_vpc.id
}

output "private_subnet_id" {
  value = aws_subnet.the_private_subnet.id
}

output "public_subnet_id" {
  value = aws_subnet.the_public_subnet.id
}