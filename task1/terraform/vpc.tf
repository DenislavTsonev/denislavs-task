module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "v5.7.1"

#   count = var.create_vpc ? 1 : 0

  name = "${local.name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = [for k, v in slice(data.aws_availability_zones.available.names, 0, 3) : cidrsubnet("10.0.0.0/19", 5, k)]
  public_subnets  = [for k, v in slice(data.aws_availability_zones.available.names, 0, 3) : cidrsubnet("10.0.64.0/19", 5, k)]

  database_subnets = [for k, v in slice(data.aws_availability_zones.available.names, 0, 3) : cidrsubnet("10.0.128.0/19", 5, k)]

  create_database_subnet_group = true

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = var.tags
}