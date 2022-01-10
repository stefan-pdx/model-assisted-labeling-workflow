variable "vpc_id" {
  type        = string
  description = "The VPC id used for making the Lambda security group"
}

variable "subnet_id" {
  type        = string
  description = "The subnet used for Lambda execution to allow EFS access"
}

variable "compute_cluster_arn" {
  type        = string
  description = "The compute cluster ARN"
}

variable "source_dataset_bucket_name" {
  type        = string
  description = "The name of the S3 bucket containing the source dataset"
  // TODO: default = "..."
}

variable "file_system_id" {
  type        = string
  description = "The EFS file system id that is used for storing data"
}

variable "file_system_mount_target_id" {
  type        = string
  description = "The EFS mount target for storage. The Lambda function has a dependency on this."
}

variable "training_dataset_file_system_access_point_id" {
  type        = string
  description = "The file system access point for the training dataset"
}

variable "source_dataset_file_system_access_point_id" {
  type        = string
  description = "The file system access point for the source dataset"
}

variable "model_file_system_access_point_id" {
  type        = string
  description = "The file system access point for the model"
}

variable "segmentation_masks_file_system_access_point_id" {
  type        = string
  description = "The file system access point for the segmentation masks"
}