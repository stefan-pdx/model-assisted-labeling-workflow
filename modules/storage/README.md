<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_efs_access_point.model](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point) | resource |
| [aws_efs_access_point.segmentation_masks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point) | resource |
| [aws_efs_access_point.source_dataset](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point) | resource |
| [aws_efs_access_point.training_dataset](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_access_point) | resource |
| [aws_efs_file_system.file_system](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system) | resource |
| [aws_efs_file_system_policy.file_system_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system_policy) | resource |
| [aws_efs_mount_target.file_system_mount_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target) | resource |
| [aws_s3_bucket.images_and_segmentation_masks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_security_group.file_system_mount_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [random_string.bucket_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_subnet.subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_read_model_role_arns"></a> [read\_model\_role\_arns](#input\_read\_model\_role\_arns) | The IAM roles allowed to read from the model file system access point | `list(string)` | n/a | yes |
| <a name="input_read_segmentation_masks_role_arns"></a> [read\_segmentation\_masks\_role\_arns](#input\_read\_segmentation\_masks\_role\_arns) | The IAM roles allowed to read from the segmentation masks file system access point | `list(string)` | n/a | yes |
| <a name="input_read_source_dataset_role_arns"></a> [read\_source\_dataset\_role\_arns](#input\_read\_source\_dataset\_role\_arns) | The IAM roles allowed to read from the source dataset file system access point | `list(string)` | n/a | yes |
| <a name="input_read_training_dataset_role_arns"></a> [read\_training\_dataset\_role\_arns](#input\_read\_training\_dataset\_role\_arns) | The IAM roles allowed to read from the training dataset file system access point | `list(string)` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The subnet id used by the file system when creating a mount target | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC id used when creating the security group for the mount target | `string` | n/a | yes |
| <a name="input_write_model_role_arns"></a> [write\_model\_role\_arns](#input\_write\_model\_role\_arns) | The IAM roles allowed to write to the model file system access point | `list(string)` | n/a | yes |
| <a name="input_write_segmentation_masks_role_arns"></a> [write\_segmentation\_masks\_role\_arns](#input\_write\_segmentation\_masks\_role\_arns) | The IAM roles allowed to write to the segmentation masks file system access point | `list(string)` | n/a | yes |
| <a name="input_write_source_dataset_role_arns"></a> [write\_source\_dataset\_role\_arns](#input\_write\_source\_dataset\_role\_arns) | The IAM roles allowed to write to the source dataset file system acceess point | `list(string)` | n/a | yes |
| <a name="input_write_training_dataset_role_arns"></a> [write\_training\_dataset\_role\_arns](#input\_write\_training\_dataset\_role\_arns) | The IAM roles allowed to write to the training dataset file system acceess point | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_file_system_id"></a> [file\_system\_id](#output\_file\_system\_id) | The EFS file system id |
| <a name="output_file_system_mount_target_id"></a> [file\_system\_mount\_target\_id](#output\_file\_system\_mount\_target\_id) | The file system mount target |
| <a name="output_model_file_system_access_point_id"></a> [model\_file\_system\_access\_point\_id](#output\_model\_file\_system\_access\_point\_id) | The file system access point for the model |
| <a name="output_segmentation_masks_file_system_access_point_id"></a> [segmentation\_masks\_file\_system\_access\_point\_id](#output\_segmentation\_masks\_file\_system\_access\_point\_id) | The file system access point for segmentation masks |
| <a name="output_source_dataset_file_system_access_point_id"></a> [source\_dataset\_file\_system\_access\_point\_id](#output\_source\_dataset\_file\_system\_access\_point\_id) | The file system access point for the source dataset |
| <a name="output_training_dataset_file_system_access_point_id"></a> [training\_dataset\_file\_system\_access\_point\_id](#output\_training\_dataset\_file\_system\_access\_point\_id) | The file system access point for the training dataset |
<!-- END_TF_DOCS -->