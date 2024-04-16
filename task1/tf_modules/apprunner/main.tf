resource "aws_apprunner_service" "this" {

  service_name                   = var.service_name
  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.this.arn

  dynamic "network_configuration" {
    for_each = length(var.network_configuration) > 0 ? [var.network_configuration] : []

    content {
      dynamic "ingress_configuration" {
        for_each = try([network_configuration.value.ingress_configuration], [])

        content {
          is_publicly_accessible = try(ingress_configuration.value.is_publicly_accessible, null)
        }
      }

      dynamic "egress_configuration" {
        for_each = try([network_configuration.value.egress_configuration], [])

        content {
          egress_type       = try(egress_configuration.value.egress_type, "VPC")
          vpc_connector_arn = try(egress_configuration.value.vpc_connector_arn, aws_apprunner_vpc_connector.this[0].arn, null)
        }
      }
    }
  }

  dynamic "source_configuration" {
    for_each = [var.source_configuration]

    content {
      dynamic "authentication_configuration" {
        for_each = try([source_configuration.value.authentication_configuration], [])

        content {
          # We can provide access_role_arn or connection_arn, not both. Have to improve this
          access_role_arn = authentication_configuration.value.connection_arn == null ? lookup(authentication_configuration.value, "access_role_arn", aws_iam_role.build[0].arn) : null
          connection_arn  = try(authentication_configuration.value.connection_arn, null)
        }
      }

      # Must be false when using public images or cross account images
      auto_deployments_enabled = try(source_configuration.value.auto_deployments_enabled, false)

      dynamic "code_repository" {
        for_each = try([source_configuration.value.code_repository], [])

        content {
          dynamic "code_configuration" {
            for_each = try([code_repository.value.code_configuration], [])

            content {
              dynamic "code_configuration_values" {
                for_each = try([code_configuration.value.code_configuration_values], [])

                content {
                  build_command                 = try(code_configuration_values.value.build_command, null)
                  port                          = try(code_configuration_values.value.port, null)
                  runtime                       = code_configuration_values.value.runtime
                  runtime_environment_variables = try(code_configuration_values.value.runtime_environment_variables, {})
                  runtime_environment_secrets   = try(code_configuration_values.value.runtime_environment_secrets, {})
                  start_command                 = try(code_configuration_values.value.start_command, null)
                }
              }

              configuration_source = code_configuration.value.configuration_source
            }
          }

          repository_url   = code_repository.value.repository_url
          source_directory = code_repository.value.source_directory

          dynamic "source_code_version" {
            for_each = [code_repository.value.source_code_version]

            content {
              type  = try(source_code_version.value.type, "BRANCH")
              value = source_code_version.value.value
            }
          }
        }

      }

      dynamic "image_repository" {
        for_each = try([source_configuration.value.image_repository], [])

        content {
          dynamic "image_configuration" {
            for_each = try([image_repository.value.image_configuration], [])

            content {
              port                          = try(image_configuration.value.port, null)
              runtime_environment_variables = try(image_configuration.value.runtime_environment_variables, {})
              runtime_environment_secrets   = try(image_configuration.value.runtime_environment_secrets, {})
              start_command                 = try(image_configuration.value.start_command, null)
            }
          }

          image_identifier      = image_repository.value.image_identifier
          image_repository_type = image_repository.value.image_repository_type
        }
      }
    }
  }

  dynamic "encryption_configuration" {
    for_each = length(var.encryption_configuration) > 0 ? [var.encryption_configuration] : []

    content {
      kms_key = encryption_configuration.value.kms_key
    }
  }

  dynamic "health_check_configuration" {
    for_each = var.health_check_configuration

    content {
      healthy_threshold   = try(health_check_configuration.value.healthy_threshold, null)
      interval            = try(health_check_configuration.value.interval, null)
      path                = try(health_check_configuration.value.path, null)
      protocol            = try(health_check_configuration.value.protocol, null)
      timeout             = try(health_check_configuration.value.timeout, null)
      unhealthy_threshold = try(health_check_configuration.value.unhealthy_threshold, null)
    }
  }

  instance_configuration {
    cpu               = try(var.instance_configuration.cpu, null)
    instance_role_arn = lookup(var.instance_configuration, "instance_role_arn", aws_iam_role.tasks.arn)
    memory            = try(var.instance_configuration.memory, null)
  }

  tags = var.tags
}

resource "aws_apprunner_auto_scaling_configuration_version" "this" {
  auto_scaling_configuration_name = "${var.service_name}-asc"
  max_concurrency                 = var.max_concurrency
  max_size                        = var.max_size
  min_size                        = var.min_size

  tags = var.tags
}

data "aws_iam_policy_document" "build_assume_role" {
  count = var.source_configuration["authentication_configuration"]["connection_arn"] == "" ? 1 : 0
  statement {
    sid     = "buildAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["build.apprunner.${data.aws_partition.current.dns_suffix}"]
    }
  }
}

resource "aws_iam_role" "build" {
  count = var.source_configuration["authentication_configuration"]["connection_arn"] == "" ? 1 : 0

  name        = "${var.service_name}-role-build"
  path        = var.build_iam_role_path
  description = var.build_iam_role_description

  assume_role_policy    = data.aws_iam_policy_document.build_assume_role[0].json
  permissions_boundary  = var.build_iam_role_permissions_boundary
  force_detach_policies = true

  tags = var.tags
}

data "aws_iam_policy_document" "build" {
  count = var.source_configuration["authentication_configuration"]["connection_arn"] == "" ? 1 : 0

  statement {
    sid = "ReadPrivateEcr"
    actions = [
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:GetDownloadUrlForLayer",
    ]
    resources = ["*"]
  }

  statement {
    sid = "AuthPrivateEcr"
    actions = [
      "ecr:DescribeImages",
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "build" {
  count = var.source_configuration["authentication_configuration"]["connection_arn"] == "" ? 1 : 0
  
  name        = "${var.service_name}-policy-build"
  path        = var.build_iam_role_path
  description = var.build_iam_role_description

  policy = data.aws_iam_policy_document.build[0].json
}

resource "aws_iam_role_policy_attachment" "build" {
  count = var.source_configuration["authentication_configuration"]["connection_arn"] == "" ? 1 : 0
  
  policy_arn = aws_iam_policy.build[0].arn
  role       = aws_iam_role.build[0].name
}

resource "aws_iam_role_policy_attachment" "build_additional" {
  for_each = var.source_configuration["authentication_configuration"]["connection_arn"] == "" ? toset(var.build_iam_role_policies) : []

  policy_arn = each.key
  role       = aws_iam_role.build[0].name
}

################################################################################
# IAM Role - Instance
################################################################################

data "aws_iam_policy_document" "tasks_assume_role" {
  statement {
    sid     = "tasksAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["tasks.apprunner.${data.aws_partition.current.dns_suffix}"]
    }
  }
}

resource "aws_iam_role" "tasks" {
  name        = "${var.service_name}-role-tasks"
  path        = var.tasks_iam_role_path
  description = var.tasks_iam_role_description

  assume_role_policy    = data.aws_iam_policy_document.tasks_assume_role.json
  permissions_boundary  = var.tasks_iam_role_permissions_boundary
  force_detach_policies = true

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "tasks_additional" {
  for_each = toset(var.tasks_iam_role_policies)

  policy_arn = each.key
  role       = aws_iam_role.tasks.name
}

################################################################################
# VPC Ingress Configuration
################################################################################

resource "aws_apprunner_vpc_ingress_connection" "this" {
  count = var.create_ingress_vpc_connection ? 1 : 0

  name        = var.service_name
  service_arn = aws_apprunner_service.this.arn

  ingress_vpc_configuration {
    vpc_id          = var.ingress_vpc_id
    vpc_endpoint_id = var.ingress_vpc_endpoint_id
  }

  tags = var.tags
}

################################################################################
# VPC Connector
################################################################################
resource "aws_apprunner_vpc_connector" "this" {
  count = var.create_vpc_connector ? 1 : 0

  vpc_connector_name = "${var.service_name}-vpc-connector"
  subnets            = var.vpc_connector_subnets
  security_groups    = var.vpc_connector_security_groups

  tags = var.tags
}
