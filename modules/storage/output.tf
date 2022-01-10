output "file_system_id" {
  description = "The EFS file system id"
  value       = aws_efs_file_system.file_system.id
}

output "file_system_mount_target_id" {
  description = "The file system mount target"
  value       = aws_efs_mount_target.file_system_mount_target.id
}

output "training_dataset_file_system_access_point_id" {
  description = "The file system access point for the training dataset"
  value       = aws_efs_access_point.training_dataset.id
}

output "source_dataset_file_system_access_point_id" {
  description = "The file system access point for the source dataset"
  value       = aws_efs_access_point.source_dataset.id
}

output "model_file_system_access_point_id" {
  description = "The file system access point for the model"
  value       = aws_efs_access_point.model.id
}
output "segmentation_masks_file_system_access_point_id" {
  description = "The file system access point for segmentation masks"
  value       = aws_efs_access_point.segmentation_masks.id
}
