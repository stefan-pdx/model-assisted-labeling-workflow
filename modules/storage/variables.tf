variable "subnet_id" {
  type        = string
  description = "The subnet id used by the file system when creating a mount target"
}

variable "read_training_dataset_role_arns" {
  type        = list(string)
  description = "The IAM roles allowed to read from the training dataset file system access point"
}

variable "write_training_dataset_role_arns" {
  type        = list(string)
  description = "The IAM roles allowed to write to the training dataset file system acceess point"
}

variable "read_source_dataset_role_arns" {
  type        = list(string)
  description = "The IAM roles allowed to read from the source dataset file system access point"
}

variable "write_source_dataset_role_arns" {
  type        = list(string)
  description = "The IAM roles allowed to write to the source dataset file system acceess point"
}

variable "read_model_role_arns" {
  type = list(string)
  description = "The IAM roles allowed to read from the model file system access point"
}

variable "write_model_role_arns" {
  type = list(string)
  description = "The IAM roles allowed to write to the model file system access point"
}

variable "read_segmentation_masks_role_arns" {
  type = list(string)
  description = "The IAM roles allowed to read from the segmentation masks file system access point"
}

variable "write_segmentation_masks_role_arns" {
  type = list(string)
  description = "The IAM roles allowed to write to the segmentation masks file system access point"
}

variable "vpc_id" {
  type        = string
  description = "The VPC id used when creating the security group for the mount target"
}