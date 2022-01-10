resource "aws_efs_file_system" "file_system" {
  creation_token   = "filesystem"
  performance_mode = "maxIO"
}

resource "aws_efs_access_point" "training_dataset" {
  file_system_id = aws_efs_file_system.file_system.id

  posix_user {
    gid = 0
    uid = 0
  }

  root_directory {
    path = "/training_dataset"

    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = "755"
    }
  }
}

resource "aws_efs_access_point" "source_dataset" {
  file_system_id = aws_efs_file_system.file_system.id

  posix_user {
    gid = 0
    uid = 0
  }

  root_directory {
    path = "/source_dataset"

    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = "755"
    }
  }
}

resource "aws_efs_access_point" "model" {
  file_system_id = aws_efs_file_system.file_system.id

  posix_user {
    gid = 0
    uid = 0
  }

  root_directory {
    path = "/model"

    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = "755"
    }
  }
}

resource "aws_efs_access_point" "segmentation_masks" {
  file_system_id = aws_efs_file_system.file_system.id

  posix_user {
    gid = 0
    uid = 0
  }

  root_directory {
    path = "/segmentation_masks"

    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = "755"
    }
  }
}

data "aws_subnet" "subnet" {
  id = var.subnet_id
}

resource "aws_security_group" "file_system_mount_target" {
  name   = "file-system-mount-target"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [data.aws_subnet.subnet.cidr_block]
  }

  egress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [data.aws_subnet.subnet.cidr_block]
  }
}

resource "aws_efs_mount_target" "file_system_mount_target" {
  file_system_id  = aws_efs_file_system.file_system.id
  subnet_id       = var.subnet_id
  security_groups = [aws_security_group.file_system_mount_target.id]
}

resource "aws_efs_file_system_policy" "file_system_policy" {
  file_system_id = aws_efs_file_system.file_system.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {"AWS": var.read_training_dataset_role_arns}
        Resource  = aws_efs_file_system.file_system.arn
        Action    = ["elasticfilesystem:ClientMount"]

        Condition = {
          StringEquals = {
            "elasticfilesystem:AccessPointArn" = aws_efs_access_point.training_dataset.arn
          }
        }
      },
      {
        Effect    = "Allow"
        Principal = {"AWS": var.write_training_dataset_role_arns}
        Resource  = aws_efs_file_system.file_system.arn

        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess"
        ]

        Condition = {
          StringEquals = {
            "elasticfilesystem:AccessPointArn" = aws_efs_access_point.training_dataset.arn
          }
        }
      },
      {
        Effect    = "Allow"
        Principal = {"AWS": var.read_source_dataset_role_arns}
        Resource  = aws_efs_file_system.file_system.arn
        Action    = ["elasticfilesystem:ClientMount"]

        Condition = {
          StringEquals = {
            "elasticfilesystem:AccessPointArn" = aws_efs_access_point.source_dataset.arn
          }
        }
      },
      {
        Effect    = "Allow"
        Principal = {"AWS": var.write_source_dataset_role_arns}
        Resource  = aws_efs_file_system.file_system.arn

        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess"
        ]

        Condition = {
          StringEquals = {
            "elasticfilesystem:AccessPointArn" = aws_efs_access_point.source_dataset.arn
          }
        }
      },
      {
        Effect    = "Allow"
        Principal = {"AWS": var.read_model_role_arns}
        Resource  = aws_efs_file_system.file_system.arn
        Action    = ["elasticfilesystem:ClientMount"]

        Condition = {
          StringEquals = {
            "elasticfilesystem:AccessPointArn" = aws_efs_access_point.model.arn
          }
        }
      },
      {
        Effect    = "Allow"
        Principal = {"AWS": var.write_model_role_arns}
        Resource  = aws_efs_file_system.file_system.arn

        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess"
        ]

        Condition = {
          StringEquals = {
            "elasticfilesystem:AccessPointArn" = aws_efs_access_point.model.arn
          }
        }
      },
      {
        Effect    = "Allow"
        Principal = {"AWS": var.read_segmentation_masks_role_arns}
        Resource  = aws_efs_file_system.file_system.arn
        Action    = ["elasticfilesystem:ClientMount"]

        Condition = {
          StringEquals = {
            "elasticfilesystem:AccessPointArn" = aws_efs_access_point.segmentation_masks.arn
          }
        }
      },
      {
        Effect    = "Allow"
        Principal = {"AWS": var.write_segmentation_masks_role_arns}
        Resource  = aws_efs_file_system.file_system.arn

        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess"
        ]

        Condition = {
          StringEquals = {
            "elasticfilesystem:AccessPointArn" = aws_efs_access_point.segmentation_masks.arn
          }
        }
      }
    ]
  })
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket" "images_and_segmentation_masks" {
  bucket = "images-and-segmentation-masks-${random_string.bucket_suffix.id}"
}