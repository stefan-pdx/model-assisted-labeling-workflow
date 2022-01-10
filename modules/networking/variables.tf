variable "vpc_id" {
  type        = string
  description = "The VPC id used when creating network resources"
}

variable "vpc_cidr_block" {
  type        = string
  description = "The VPC's CIDR block"
}

variable "availability_zone" {
  type        = string
  description = "The availability zone associated with the VPC"
}