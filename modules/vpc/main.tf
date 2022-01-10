resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
}

resource "aws_vpc_dhcp_options" "dhcp_options" {
  domain_name_servers = ["AmazonProvidedDNS"]
}

resource "aws_vpc_dhcp_options_association" "vpc_dhcp_options" {
  vpc_id          = aws_vpc.vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.dhcp_options.id
}

data "aws_availability_zones" "available" {}

locals {
  availability_zone = data.aws_availability_zones.available.names[0]
}

data "aws_region" "current" {}

locals {
  aws_region = data.aws_region.current.name
}