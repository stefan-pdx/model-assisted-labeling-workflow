output "pipeline_tasks_repository_url" {
  description = "The ECR repository url for the pipeline tasks container image"
  value       = aws_ecr_repository.pipeline_tasks.repository_url
}


output "import_training_dataset_to_efs_lambda_role_arn" {
  description = "The IAM role of the Lambda that imports training dataset to EFS"
  value       = aws_iam_role.import_training_dataset_to_efs_lambda.arn
}

output "import_source_dataset_to_efs_lambda_role_arn" {
  description = "The IAM role of the Lambda that imports the source dataset to EFS"
  value       = aws_iam_role.import_source_dataset_to_efs_lambda.arn
}

output "train_model_task_role_arn" {
  description = "The IAM role of the ECS task that trains the model"
  value       = aws_iam_role.train_model_task.arn
}

output "compute_segmentation_masks_for_source_dataset_task_role_arn" {
  description = "The IAM role of the ECS task that compute segmentation masks for the source dataset"
  value       = aws_iam_role.compute_segmentation_masks_for_source_dataset_task.arn
}

output "import_source_dataset_to_labelbox_lambda_role_arn" {
  description = "The IAM role of the Lambda that imports the source dataset to Labelbox"
  value       = aws_iam_role.import_source_dataset_to_labelbox_lambda.arn
}

output "import_source_dataset_segmentation_masks_to_labelbox_lambda_role_arn" {
  description = "The IAM role of the Lambda that imports the source dataset segmentation masks to Labelbox"
  value       = aws_iam_role.import_source_dataset_segmentation_masks_to_labelbox_lambda.arn
}

output "state_machine_arn" {
  description = "The ARN of the state machine used for executing the pipeline"
  value       = aws_sfn_state_machine.pipeline.arn
}