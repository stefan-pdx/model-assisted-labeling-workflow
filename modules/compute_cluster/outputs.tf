output "arn" {
  description = "The computer cluster ARN"
  value       = aws_ecs_cluster.compute_cluster.arn
}

output "role_arn" {
  description = "The compute cluster role ARN"
  value       = aws_iam_role.compute_cluster.arn
}