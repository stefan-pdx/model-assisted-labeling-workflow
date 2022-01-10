# BEGIN: import-training-dataset-to-efs

resource "aws_iam_role" "import_training_dataset_to_efs_lambda" {
  name               = "import-training-dataset-to-efs-lambda"
  assume_role_policy = data.aws_iam_policy_document.allow_lambda_service_to_assume_role.json
}

resource "aws_lambda_function" "import_training_dataset_to_efs" {
  function_name    = "import-training-dataset-to-efs"
  filename         = data.archive_file.lambda_package.output_path
  layers           = [aws_lambda_layer_version.pipeline_dependencies.arn]
  handler          = "lambdas.import_training_dataset_to_efs"
  source_code_hash = local.lambda_source_code_hash
  runtime          = "python3.8"
  timeout          = 300
  role             = aws_iam_role.import_training_dataset_to_efs_lambda.arn

  file_system_config {
    arn              = data.aws_efs_access_point.training_dataset.arn
    local_mount_path = "/mnt/training_dataset"
  }

  vpc_config {
    subnet_ids         = [var.subnet_id]
    security_group_ids = [aws_security_group.pipeline_execution.id]
  }

  depends_on = [var.file_system_mount_target_id]
}

# END: import-training-dataset-to-efs-lambda

# BEGIN: import-source-dataset-to-efs-lambda

resource "aws_iam_role" "import_source_dataset_to_efs_lambda" {
  name               = "import-source-dataset-to-efs-lambda"
  assume_role_policy = data.aws_iam_policy_document.allow_lambda_service_to_assume_role.json
}


resource "aws_lambda_function" "import_source_dataset_to_efs" {
  function_name    = "import-source-dataset-to-efs"
  filename         = data.archive_file.lambda_package.output_path
  layers           = [aws_lambda_layer_version.pipeline_dependencies.arn]
  handler          = "lambdas.import_source_dataset_to_efs"
  source_code_hash = local.lambda_source_code_hash
  runtime          = "python3.8"
  timeout          = 300
  role             = aws_iam_role.import_source_dataset_to_efs_lambda.arn

  file_system_config {
    arn              = data.aws_efs_access_point.source_dataset.arn
    local_mount_path = "/mnt/source_dataset"
  }

  vpc_config {
    subnet_ids         = [var.subnet_id]
    security_group_ids = [aws_security_group.pipeline_execution.id]
  }

  depends_on = [var.file_system_mount_target_id]
}

# END: import-source-dataset-to-efs-lambda

# BEGIN: train-model-task

resource "aws_iam_role" "train_model_task" {
  name               = "train-model-task"
  assume_role_policy = data.aws_iam_policy_document.allow_ecs_tasks_service_to_assume_role.json
}

resource "aws_ecs_task_definition" "train_model" {
  family        = "train-model"
  task_role_arn = aws_iam_role.train_model_task.arn

  container_definitions = jsonencode([
    {
      name     = "train"
      image    = "${aws_ecr_repository.pipeline_tasks.repository_url}:latest"
      command  = ["train_model"]

      cpu       = 6
      memory    = 12288

      mountPoints = [
        {
          sourceVolume  = "training_dataset"
          containerPath = "/mnt/training_dataset"
        },
        {
          sourceVolume  = "model"
          containerPath = "/mnt/model"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.pipeline.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "train-model"
        }
      }
    }
  ])

  volume {
    name = "training_dataset"

    efs_volume_configuration {
      file_system_id     = var.file_system_id
      transit_encryption = "ENABLED"

      authorization_config {
        access_point_id = var.training_dataset_file_system_access_point_id
        iam             = "ENABLED"
      }
    }
  }

  volume {
    name = "model"

    efs_volume_configuration {
      file_system_id     = var.file_system_id
      transit_encryption = "ENABLED"

      authorization_config {
        access_point_id = var.model_file_system_access_point_id
        iam             = "ENABLED"
      }
    }
  }
}

# END: train-model-task

# BEGIN: compute-segmentation-masks-for-source-dataset-task

resource "aws_iam_role" "compute_segmentation_masks_for_source_dataset_task" {
  name               = "compute-segmentation-masks-for-source-dataset-task"
  assume_role_policy = data.aws_iam_policy_document.allow_ecs_tasks_service_to_assume_role.json
}

resource "aws_ecs_task_definition" "compute_segmentation_masks_for_source_dataset" {
  family        = "train-model"
  task_role_arn = aws_iam_role.compute_segmentation_masks_for_source_dataset_task.arn

  container_definitions = jsonencode([
    {
      name     = "train"
      image    = "${aws_ecr_repository.pipeline_tasks.repository_url}:latest"
      command  = ["compute_segmentation_masks_for_source_dataset"]

      cpu       = 1
      memory    = 4096

      mountPoints = [
        {
          sourceVolume  = "source_dataset"
          containerPath = "/mnt/source_dataset"
        },
        {
          sourceVolume  = "model"
          containerPath = "/mnt/model"
        },
        {
          sourceVolume  = "segmentation_masks"
          containerPath = "/mnt/segmentation_masks"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.pipeline.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "compute-segmentation-masks-for-source-dataset"
        }
      }
    }
  ])

  volume {
    name = "source_dataset"

    efs_volume_configuration {
      file_system_id     = var.file_system_id
      transit_encryption = "ENABLED"

      authorization_config {
        access_point_id = var.source_dataset_file_system_access_point_id
        iam             = "ENABLED"
      }
    }
  }

  volume {
    name = "model"

    efs_volume_configuration {
      file_system_id     = var.file_system_id
      transit_encryption = "ENABLED"

      authorization_config {
        access_point_id = var.model_file_system_access_point_id
        iam             = "ENABLED"
      }
    }
  }

  volume {
    name = "source_dataset"

    efs_volume_configuration {
      file_system_id     = var.file_system_id
      transit_encryption = "ENABLED"

      authorization_config {
        access_point_id = var.source_dataset_file_system_access_point_id
        iam             = "ENABLED"
      }
    }
  }

  volume {
    name = "segmentation_masks"

    efs_volume_configuration {
      file_system_id     = var.file_system_id
      transit_encryption = "ENABLED"

      authorization_config {
        access_point_id = var.segmentation_masks_file_system_access_point_id
        iam             = "ENABLED"
      }
    }
  }
}

# END: compute-segmentation-masks-for-source-dataset-task

# BEGIN: import-source-dataset-to-labelbox

resource "aws_iam_role" "import_source_dataset_to_labelbox_lambda" {
  name               = "import-source-dataset-to-labelbox-lambda"
  assume_role_policy = data.aws_iam_policy_document.allow_lambda_service_to_assume_role.json
}

resource "aws_lambda_function" "import_source_dataset_to_labelbox" {
  function_name    = "import-source-dataset-to-labelbox"
  filename         = data.archive_file.lambda_package.output_path
  layers           = [aws_lambda_layer_version.pipeline_dependencies.arn]
  handler          = "lambdas.import_source_dataset_to_labelbox"
  source_code_hash = local.lambda_source_code_hash
  runtime          = "python3.8"
  timeout          = 300
  role             = aws_iam_role.import_source_dataset_to_labelbox_lambda.arn

  file_system_config {
    arn              = data.aws_efs_access_point.source_dataset.arn
    local_mount_path = "/mnt/source_dataset"
  }

  vpc_config {
    subnet_ids         = [var.subnet_id]
    security_group_ids = [aws_security_group.pipeline_execution.id]
  }

  depends_on = [var.file_system_mount_target_id]
}

# END: import-source-dataset-to-labelbox

# BEGIN: import-source-dataset-segmentation-masks-to-labelbox

resource "aws_iam_role" "import_source_dataset_segmentation_masks_to_labelbox_lambda" {
  name               = "import-source-dataset-segmentation-masks-to-labelbox-lambda"
  assume_role_policy = data.aws_iam_policy_document.allow_lambda_service_to_assume_role.json
}

resource "aws_lambda_function" "import_source_dataset_segmentation_masks_to_labelbox" {
  function_name    = "import-source-dataset-segmentation-masks-to-labelbox"
  filename         = data.archive_file.lambda_package.output_path
  layers           = [aws_lambda_layer_version.pipeline_dependencies.arn]
  handler          = "lambdas.import_source_dataset_segmentation_masks_to_labelbox"
  source_code_hash = local.lambda_source_code_hash
  runtime          = "python3.8"
  timeout          = 300
  role             = aws_iam_role.import_source_dataset_segmentation_masks_to_labelbox_lambda.arn

  file_system_config {
    arn              = data.aws_efs_access_point.segmentation_masks.arn
    local_mount_path = "/mnt/segmentation_masks"
  }

  vpc_config {
    subnet_ids         = [var.subnet_id]
    security_group_ids = [aws_security_group.pipeline_execution.id]
  }

  depends_on = [var.file_system_mount_target_id]
}

# END: import-source-dataset-segmentation-masks-to-labelbox

# BEGIN: pipeline

resource "aws_iam_role" "pipeline_execution" {
  name               = "pipeline-execution"
  assume_role_policy = data.aws_iam_policy_document.allow_states_service_to_assume_role.json
}

resource "aws_sfn_state_machine" "pipeline" {
  name       = "pipeline"
  role_arn   = aws_iam_role.pipeline_execution.arn
  definition = jsonencode({
    StartAt = "ImportingTrainingDatasetToEFS"
    States  = {
      ImportingTrainingDatasetToEFS = {
        Type       = "Task"
        Resource   = "arn:aws:states:::lambda:invoke"
        Next       = "ImportingSourceDatasetToEFS"
        Parameters = {
          FunctionName = aws_lambda_function.import_training_dataset_to_efs.function_name
        }
      },
      ImportingSourceDatasetToEFS = {
        Type       = "Task"
        Resource   = "arn:aws:states:::lambda:invoke"
        Next       = "TrainingModel"
        Parameters = {
          FunctionName = aws_lambda_function.import_source_dataset_to_efs.function_name
          Payload = {
            source_dataset_bucket_name = var.source_dataset_bucket_name
          }
        }
      },
      TrainingModel = {
        Type       = "Task"
        Resource   = "arn:aws:states:::ecs:runTask.sync"
        Next       = "ComputingSegmentationMasksForSourceDataset"
        Parameters = {
          Cluster        = var.compute_cluster_arn
          TaskDefinition = aws_ecs_task_definition.train_model.arn
        }
      },
      ComputingSegmentationMasksForSourceDataset = {
        Type       = "Task"
        Resource   = "arn:aws:states:::ecs:runTask.sync"
        Next       = "ImportingSourceDatasetToLabelbox"
        Parameters = {
          Cluster        = var.compute_cluster_arn
          TaskDefinition = aws_ecs_task_definition.compute_segmentation_masks_for_source_dataset.arn
        }
      },
      ImportingSourceDatasetToLabelbox = {
        Type       = "Task"
        Resource   = "arn:aws:states:::lambda:invoke"
        Next       = "ImportingSourceDatasetSegmentationMasksToLabelbox"
        Parameters = {
          FunctionName = aws_lambda_function.import_source_dataset_to_labelbox.function_name
        }
      },
      ImportingSourceDatasetSegmentationMasksToLabelbox = {
        Type       = "Task"
        Resource   = "arn:aws:states:::lambda:invoke"
        End        = true
        Parameters = {
          FunctionName = aws_lambda_function.import_source_dataset_segmentation_masks_to_labelbox.function_name
        }
      }
    }
  })
}

# END: pipeline

# BEGIN: iam-policy-documents

data "aws_iam_policy_document" "allow_lambda_service_to_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "allow_ecs_tasks_service_to_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "allow_states_service_to_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["states.${data.aws_region.current.name}.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "allow_publishing_log_streams_to_pipeline_log_group" {
  statement {
    actions   = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [aws_cloudwatch_log_group.pipeline.arn]
  }
}

data "aws_iam_policy_document" "allow_step_function_to_get_ecs_task_events" {
  statement {
    actions = [
      "events:PutTargets",
      "events:PutRule",
      "events:DescribeRule"
    ]

    resources = ["arn:aws:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:rule/StepFunctionsGetEventsForECSTaskRule"]
  }
}

data "aws_iam_policy_document" "allow_running_pipeline_tasks" {
  statement {
    actions = ["ecs:RunTask"]

    resources = [
      aws_ecs_task_definition.train_model.arn,
      aws_ecs_task_definition.compute_segmentation_masks_for_source_dataset.arn
    ]
  }
}

data "aws_iam_policy_document" "allow_invoking_pipeline_lambdas" {
  statement {
    actions   = ["lambda:InvokeFunction"]

    resources = [
      aws_lambda_function.import_training_dataset_to_efs.arn,
      aws_lambda_function.import_source_dataset_to_efs.arn,
      aws_lambda_function.import_source_dataset_to_labelbox.arn,
      aws_lambda_function.import_source_dataset_segmentation_masks_to_labelbox.arn
    ]
  }
}

data "aws_s3_bucket" "source_dataset_bucket" {
  bucket = var.source_dataset_bucket_name
}

data "aws_iam_policy_document" "allow_importing_from_source_dataset_bucket" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = [data.aws_s3_bucket.source_dataset_bucket.arn]
  }

  statement {
    actions   = ["s3:GetObject"]
    resources = ["${data.aws_s3_bucket.source_dataset_bucket.arn}/*"]
  }
}

# END: iam-policy-documents

# BEGIN: iam-policies

resource "aws_iam_policy" "allow_publishing_log_streams_to_pipeline_log_group" {
  name   = "allow-publishing-log-streams-to-pipeline-log-group"
  policy = data.aws_iam_policy_document.allow_publishing_log_streams_to_pipeline_log_group.json
}

resource "aws_iam_policy" "allow_running_pipeline_tasks" {
  name   = "allow-running-pipeline-tasks"
  policy = data.aws_iam_policy_document.allow_running_pipeline_tasks.json
}

resource "aws_iam_policy" "allow_step_function_to_get_ecs_task_events" {
  name = "allow-step-function-to-get-ecs-task-events"
  policy = data.aws_iam_policy_document.allow_step_function_to_get_ecs_task_events.json
}

resource "aws_iam_policy" "allow_invoking_pipeline_lambdas" {
  name   = "allow-invoking-pipeline-lambdas"
  policy = data.aws_iam_policy_document.allow_invoking_pipeline_lambdas.json
}

resource "aws_iam_policy" "allow_importing_from_source_dataset_bucket" {
  name   = "allow-importing-from-source-dataset-bucket"
  policy = data.aws_iam_policy_document.allow_importing_from_source_dataset_bucket.json
}

# END iam-policies

# BEGIN: iam-policy-attachments

locals {
  lambda_role_arns = [
    aws_iam_role.import_training_dataset_to_efs_lambda.name,
    aws_iam_role.import_source_dataset_to_efs_lambda.name,
    aws_iam_role.import_source_dataset_to_labelbox_lambda.name,
    aws_iam_role.import_source_dataset_segmentation_masks_to_labelbox_lambda.name
  ]

  tasks_role_arns = [
    aws_iam_role.train_model_task.name,
    aws_iam_role.compute_segmentation_masks_for_source_dataset_task.name,
  ]

  pipeline_task_role_arns = concat(local.lambda_role_arns, local.lambda_role_arns)
}

resource "aws_iam_policy_attachment" "allow_pipeline_lambda_vpc_access" {
  name       = "allow-pipeline-lambdas-vpc-access"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  roles      = local.lambda_role_arns
}

resource "aws_iam_policy_attachment" "allow_pipeline_tasks_efs_access" {
  name       = "allow-pipeline-tasks-efs-access"
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientReadWriteAccess"
  roles      = local.pipeline_task_role_arns
}

resource "aws_iam_policy_attachment" "allow_pipeline_tasks_to_publish_log_streams_to_pipeline_log_group" {
  name       = "allow-pipeline-tasks-to-publish-log-streams-to-pipeline-log-group"
  policy_arn = aws_iam_policy.allow_publishing_log_streams_to_pipeline_log_group.arn
  roles      = local.pipeline_task_role_arns
}

resource "aws_iam_policy_attachment" "allow_pipeline_execution_to_run_pipeline_tasks" {
  name       = "allow-pipeline-execution-to-run-pipeline-tasks"
  policy_arn = aws_iam_policy.allow_running_pipeline_tasks.arn
  roles      = [aws_iam_role.pipeline_execution.name]
}

resource "aws_iam_policy_attachment" "allow_pipeline_execution_to_get_ecs_events" {
  name       = "allow-pipeline-execution-to-get-events"
  roles      = [aws_iam_role.pipeline_execution.name]
  policy_arn = aws_iam_policy.allow_step_function_to_get_ecs_task_events.arn
}

resource "aws_iam_policy_attachment" "allow_pipeline_to_invoke_lambdas" {
  name       = "allow-pipeline-to-invoke-lambdas"
  roles      = [aws_iam_role.pipeline_execution.name]
  policy_arn = aws_iam_policy.allow_invoking_pipeline_lambdas.arn
}

resource "aws_iam_policy_attachment" "allow_pipeline_to_import_from_source_dataset_bucket" {
  name       = "allow-pipeline-to-import-from-source-dataset-bucket"
  roles      = [aws_iam_role.import_source_dataset_to_efs_lambda.name]
  policy_arn = aws_iam_policy.allow_importing_from_source_dataset_bucket.arn
}

# END: iam-policy-attachments

# BEGIN: security-group

resource "aws_security_group" "pipeline_execution" {
  name   = "pipeline-execution"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "allow_outgoing_nfs_traffic_for_pipeline_execution" {
  description        = "Allow outgoing NFS traffic (including EFS access) for pipeline execution"
  security_group_id = aws_security_group.pipeline_execution.id
  cidr_blocks       = [data.aws_vpc.vpc.cidr_block]
  type              = "egress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
}

resource "aws_security_group_rule" "allow_outgoing_https_traffic_for_pipeline_execution" {
  description       = "Allow outgoing HTTPS traffic for pipeline execution"
  security_group_id = aws_security_group.pipeline_execution.id
  cidr_blocks       = ["0.0.0.0/0"]
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
}

# END: security-group

# BEGIN: efs-access-points

data "aws_efs_access_point" "training_dataset" {
  access_point_id = var.training_dataset_file_system_access_point_id
}

data "aws_efs_access_point" "source_dataset" {
  access_point_id = var.source_dataset_file_system_access_point_id
}

data "aws_efs_access_point" "model" {
  access_point_id = var.model_file_system_access_point_id
}

data "aws_efs_access_point" "segmentation_masks" {
  access_point_id = var.segmentation_masks_file_system_access_point_id
}

# END: efs-access-points

# BEGIN: lambda-package

locals {
  lambda_source_code_hash = filebase64sha256("${path.module}/files/lambdas.py")
}

data "archive_file" "layer_package" {
  type        = "zip"
  source_dir  = "${path.module}/files/packages/layer"
  output_path = "${path.module}/files/packages/layer_package.zip"
}

resource "aws_lambda_layer_version" "pipeline_dependencies" {
  layer_name = "pipeline-dependencies"
  filename   = data.archive_file.layer_package.output_path
}

data "archive_file" "lambda_package" {
  type        = "zip"
  source_file = "${path.module}/files/lambdas.py"
  output_path = "${path.module}/files/packages/lambda_package.zip"
}

# END: lambda-package

# BEGIN: pipeline-tasks-repository

resource "aws_ecr_repository" "pipeline_tasks" {
  name = "pipeline-tasks"
}

# END: pipeline-tasks-repository

# BEGIN: cloudwatch-logs

resource "aws_cloudwatch_log_group" "pipeline" {
  name = "pipeline"
}

# END: cloudwatch-logs

# BEGIN: misc

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

# END: misc