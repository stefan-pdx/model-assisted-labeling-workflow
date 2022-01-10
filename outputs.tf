output "pipeline_tasks_repository_url" {
  description = "The pipeline tasks ECR repository url"
  value       = module.pipeline.pipeline_tasks_repository_url
}

output "aws_region" {
  description = "The AWS region used for deployment"
  value       = module.vpc.aws_region
}

output "pipeline_state_machine_arn" {
  description = "The ARN of the pipeline State Machine"
  value       = module.pipeline.state_machine_arn
}