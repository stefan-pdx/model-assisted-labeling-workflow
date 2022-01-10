output "id" {
  description = "The VPC id"
  value       = aws_vpc.vpc.id
}

output "cidr_block" {
  description = "The VPC CIDR block"
  value       = aws_vpc.vpc.cidr_block
}

output "availability_zone" {
  description = "The availability zone of the VPC"
  value       = local.availability_zone
}

output "aws_region" {
  description = "The AWS region used for deployment"
  value       = local.aws_region
}