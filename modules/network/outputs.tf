output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "vpc_cidr" {
  value = aws_vpc.main_vpc.cidr_block
}

output "main_route_table_id" {
  value = aws_route_table.public_route_table.id
}

output "igw_id" {
  value = aws_internet_gateway.main_igw.id
}

output "nat_gateway_id" {
  value = aws_eip.nat_ip[*].id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}

output "public_subnet_cidr" {
  value = aws_subnet.public_subnet[*].cidr_block
}

output "app_subnet_ids" {
  value = aws_subnet.app_subnet[*].id
}

output "app_subnet_cidr" {
  value = aws_subnet.app_subnet[*].cidr_block
}

output "database_subnet_ids" {
  value = aws_subnet.database_subnet[*].id
}

output "database_subnet_cidr" {
  value = aws_subnet.database_subnet[*].cidr_block
}

output "app_route_table_ids" {
  value = aws_route_table.app_route_table[*].id
}