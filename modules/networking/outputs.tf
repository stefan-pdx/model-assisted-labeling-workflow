output "private_subnet_id" {
  description = "The private subnet id"
  value       = aws_subnet.private_subnet.id
}

output "public_subnet_id" {
  description = "The public subnet id"
  value       = aws_subnet.public_subnet.id
}
