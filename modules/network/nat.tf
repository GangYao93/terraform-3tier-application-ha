# NAT gateway and eip
resource "aws_eip" "nat_ip" {
  count  = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.subnet_az)) : 0
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  count         = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.subnet_az)) : 0
  allocation_id = aws_eip.nat_ip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id
  tags = merge(
    var.default_tags,
    {
      Name = "${var.project_name}-${var.default_tags.Environment}-nat-${count.index}"
      Tier = "private"
    }
  )

  depends_on = [aws_internet_gateway.main_igw]
}
