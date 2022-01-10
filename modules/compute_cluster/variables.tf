variable "ami" {
  type        = string
  description = "The EC2 instance AMI for the ECS cluster"
  default     = "ami-0ec2e33c6e1161e98"
}

variable "instance_type" {
  type        = string
  description = "The EC2 instances type for the ECS cluster"
  default     = "c4.2xlarge" //"g3s.xlarge"
}

variable "vpc_id" {
  type        = string
  description = "The vpc id for creating resources"
}

variable "subnet_id" {
  type        = string
  description = "The subnet id used for EC2 instances"
}

variable "availability_zone" {
  type        = string
  description = "The availability zone provided by the network"
}