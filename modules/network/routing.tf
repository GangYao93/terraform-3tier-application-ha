#public routing table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  tags = merge(
    var.default_tags,
    {
      Name = "${var.project_name}-${var.environment}-public-rtb"
      Tier = "public"
    }
  )
}

# default route
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main_igw.id
}

# route table association
resource "aws_route_table_association" "public_route_table_association" {
  count          = length(var.public_subnet_cidr)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# frontend & backend routing table
resource "aws_route_table" "app_route_table" {
  # one app route table for each az
  count  = length(var.subnet_az)
  vpc_id = aws_vpc.main_vpc.id
  tags = merge(
    var.default_tags,
    {
      Name = "${var.project_name}-${var.environment}-app-rtb"
      Tier = "private"
    }
  )
}

# frontend & backend default route to nat
resource "aws_route" "app_default_route" {
  count          = var.enable_nat_gateway ? length(var.subnet_az) : 0
  route_table_id = aws_route_table.app_route_table[count.index].id
  # if signal nat, all traffic to that nat, otherwise each az's traffic to their own nat
  nat_gateway_id         = var.single_nat_gateway ? aws_nat_gateway.nat[0].id : aws_nat_gateway.nat[count.index].id
  destination_cidr_block = "0.0.0.0/0"
}

# frontend & backend  route binding
resource "aws_route_table_association" "app_route_binding" {
  count          = length(var.subnet_az)
  subnet_id      = aws_subnet.app_subnet[count.index].id
  route_table_id = aws_route_table.app_route_table[count.index].id
}

# database subnet route table
resource "aws_route_table" "database_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  tags = merge(
    var.default_tags,
    {
      Name = "${var.project_name}-${var.environment}-database-rtb"
      Tier = "public"
    }
  )
}

# database route binding
resource "aws_route_table_association" "database_route_table" {
  count          = length(var.subnet_az)
  subnet_id      = aws_subnet.database_subnet[count.index].id
  route_table_id = aws_route_table.database_route_table.id
}