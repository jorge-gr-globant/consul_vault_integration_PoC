output "vpc_id" {
  description = "The id of the VPC."
  value       = aws_vpc.consul.id
}

output "vpc_cidr" {
  description = "The CDIR block used for the VPC."
  value       = aws_vpc.consul.cidr_block
}

output "public_subnet_1" {
  description = "A list of the public subnets."
  value       = [aws_subnet.public-subnet-1.id]
}

output "private_subnet_1" {
  description = "A list of the private subnets."
  value       = [aws_subnet.private-subnet-1.id]
}

output "private_subnet_2" {
  description = "A list of the private subnets."
  value       = [aws_subnet.private-subnet-2.id]
}

output "private_subnet_3" {
  description = "A list of the private subnets."
  value       = [aws_subnet.private-subnet-3.id]
}

output "public_routing_table_id" {
  description = "The id of the public routing table."
  value       = aws_route_table.public-rt.id
}

output "private_routing_table_id" {
  description = "A list of the private routing tables."
  value       = aws_route_table.private-rt.id
}
