# create network
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = merge(var.default_tags, {
    Name = "${var.project_name}-${var.environment}-vpc"
  })
}



# internet gateway and route table
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = merge(
    var.default_tags,
    {
      Name = "${var.project_name}-${var.environment}-igw"
    }
  )
}




