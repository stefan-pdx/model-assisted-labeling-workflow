data "aws_iam_policy_document" "allow_ec2_service_to_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "compute_cluster" {
  name               = "compute-cluster"
  assume_role_policy = data.aws_iam_policy_document.allow_ec2_service_to_assume_role.json
}

resource "aws_iam_role_policy_attachment" "attach_ecs_policy_to_compute_cluster" {
  role       = aws_iam_role.compute_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "attach_ssm_managed_instance_core_policy_to_compute_cluster" {
  role       = aws_iam_role.compute_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "compute_cluster" {
  name = "compute-cluster"
  role = aws_iam_role.compute_cluster.name
}

resource "aws_security_group" "compute_cluster" {
  name   = "compute-cluster"
  vpc_id = var.vpc_id

  egress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "NFS"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_capacity_provider" "compute_cluster" {
  name = "compute-cluster"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.compute_cluster.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 1
    }
  }
}

locals {
  cluster_name = "compute-cluster"
}

resource "aws_launch_configuration" "compute_cluster" {
    image_id             = var.ami
    iam_instance_profile = aws_iam_instance_profile.compute_cluster.name
    security_groups      = [aws_security_group.compute_cluster.id]
    user_data            = "#!/bin/bash\necho ECS_CLUSTER=${local.cluster_name} >> /etc/ecs/ecs.config"
    instance_type        = var.instance_type
}

resource "aws_autoscaling_group" "compute_cluster" {
  name                  = local.cluster_name
  vpc_zone_identifier   = [var.subnet_id]
  launch_configuration  = aws_launch_configuration.compute_cluster.name
  desired_capacity      = 1
  min_size              = 0
  max_size              = 1
  protect_from_scale_in = true
}


resource "aws_ecs_cluster" "compute_cluster" {
  name = local.cluster_name
  capacity_providers = [aws_ecs_capacity_provider.compute_cluster.name]
}