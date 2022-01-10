module "vpc" {
  source = "./modules/vpc"
}

module "networking" {
  source = "./modules/networking"

  vpc_id            = module.vpc.id
  vpc_cidr_block    = module.vpc.cidr_block
  availability_zone = module.vpc.availability_zone
}

module "storage" {
  source = "./modules/storage"

  vpc_id    = module.vpc.id
  subnet_id = module.networking.private_subnet_id

  write_source_dataset_role_arns = [module.pipeline.import_source_dataset_to_efs_lambda_role_arn]

  write_training_dataset_role_arns = [module.pipeline.import_training_dataset_to_efs_lambda_role_arn]

  read_training_dataset_role_arns = [module.pipeline.train_model_task_role_arn]
  write_model_role_arns           = [module.pipeline.train_model_task_role_arn]

  read_source_dataset_role_arns = [
    module.pipeline.compute_segmentation_masks_for_source_dataset_task_role_arn,
    module.pipeline.import_source_dataset_to_labelbox_lambda_role_arn
  ]

  read_model_role_arns               = [module.pipeline.compute_segmentation_masks_for_source_dataset_task_role_arn]
  write_segmentation_masks_role_arns = [module.pipeline.compute_segmentation_masks_for_source_dataset_task_role_arn]

  read_segmentation_masks_role_arns = [module.pipeline.import_source_dataset_segmentation_masks_to_labelbox_lambda_role_arn]
}

module "compute_cluster" {
  source = "./modules/compute_cluster"

  vpc_id            = module.vpc.id
  availability_zone = module.vpc.availability_zone

  subnet_id         = module.networking.private_subnet_id
}

module "pipeline" {
  source = "./modules/pipeline"

  vpc_id = module.vpc.id

  subnet_id = module.networking.private_subnet_id

  file_system_id                                 = module.storage.file_system_id
  file_system_mount_target_id                    = module.storage.file_system_mount_target_id
  training_dataset_file_system_access_point_id   = module.storage.training_dataset_file_system_access_point_id
  source_dataset_file_system_access_point_id     = module.storage.source_dataset_file_system_access_point_id
  model_file_system_access_point_id              = module.storage.model_file_system_access_point_id
  segmentation_masks_file_system_access_point_id = module.storage.segmentation_masks_file_system_access_point_id

  compute_cluster_arn = module.compute_cluster.arn

  source_dataset_bucket_name = var.source_dataset_bucket_name
}