locals {
  name = "denislavs-task"
}

locals {
  updated_secret = merge(
    jsondecode(data.aws_secretsmanager_secret_version.this.secret_string),
    {
      username    = var.db_username
      bucket      = module.s3_bucket.s3_bucket_id
      db_host     = module.db.db_instance_address
      db_relation = var.db_name
    }
  )
}

locals {
  vpc_subnet_ids = var.vpc_subnet_ids != null ? var.vpc_subnet_ids : module.vpc.private_subnets
  vpc_security_group_ids = var.vpc_security_group_ids != null ? var.vpc_security_group_ids : [module.vpc.default_security_group_id]
}