module "app_runner_code_base" {
  source = "../tf_modules/apprunner"

  service_name = "${local.name}-code-base"

  source_configuration = {
    authentication_configuration = {
      connection_arn = "arn:aws:apprunner:eu-west-1:707893959875:connection/apprunner-eu2/96ad2a9f0cec441ca6bc58ea783c7042"
    }
    auto_deployments_enabled = false
    code_repository = {
      code_configuration = {
        configuration_source = "REPOSITORY"
      }
      repository_url   = "https://github.com/DenislavTsonev/denislavs-task"
      source_directory = "task1/app/"
      source_code_version = {
        type  = "BRANCH"
        value = "main"
      }
    }
  }

  create_vpc_connector          = true
  vpc_connector_subnets         = module.vpc.private_subnets
  vpc_connector_security_groups = [module.security_group_app_runner.security_group_id]

  network_configuration = {
    egress_configuration = {
      egress_type = "VPC"
    }
  }

  tasks_iam_role_policies = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  ]

  tags = var.tags

  depends_on = [ module.db ]
}

module "security_group_app_runner" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${local.name}-sg-apprunner"
  description = "AppRunner security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules = ["https-443-tcp"]

  egress_rules = ["all-all"]

  tags = var.tags
}
