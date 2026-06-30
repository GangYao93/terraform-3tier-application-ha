# public subnets
resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnet_cidr)
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.public_subnet_cidr[count.index]
  availability_zone       = var.subnet_az[count.index]
  map_public_ip_on_launch = true
  tags = merge(
    var.default_tags,
    {
      Name = "${var.project_name}-${var.environment}-public-subnet-${count.index}"
      Tier = "public"
    }
  )
}

# private subnets
resource "aws_subnet" "app_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  count             = length(var.app_subnet_cidr)
  cidr_block        = var.app_subnet_cidr[count.index]
  availability_zone = var.subnet_az[count.index]

  tags = merge(
    var.default_tags,
    {
      Name = "${var.project_name}-${var.default_tags.Environment}-app-subnet-${count.index}"
      Tier = "private"
    }
  )
}

resource "aws_subnet" "database_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  count             = length(var.database_subnet_cidr)
  cidr_block        = var.database_subnet_cidr[count.index]
  availability_zone = var.subnet_az[count.index]

  tags = merge(
    var.default_tags,
    {
      Name = "${var.project_name}-${var.default_tags.Environment}-database-subnet-${count.index}"
      Tier = "private"
    }
  )
}