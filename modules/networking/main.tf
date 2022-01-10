resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = var.vpc_id
}

locals {
  private_subnet_cidr_block = cidrsubnet(var.vpc_cidr_block, 8, 0)
  public_subnet_cidr_block = cidrsubnet(var.vpc_cidr_block, 8, 1)
}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = var.vpc_id
  cidr_block              = local.private_subnet_cidr_block
  availability_zone       = var.availability_zone
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = var.vpc_id
  cidr_block              = local.public_subnet_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone
}

resource "aws_eip" "nat_gateway" { }

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.public_subnet.id
}

resource "aws_route_table" "public_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table_association" "public_subnet_route_table_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

resource "aws_route_table_association" "private_subnet_route_table_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route" "route" {
  route_table_id              = aws_route_table.public_route_table.id
  gateway_id                  = aws_internet_gateway.internet_gateway.id
  destination_cidr_block      = "0.0.0.0/0"
}