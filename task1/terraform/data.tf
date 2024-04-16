data "aws_availability_zones" "available" {}
data "aws_partition" "current" {}


data "aws_secretsmanager_secret" "this" {
  name = "denislavs-tasks"
}

data "aws_secretsmanager_secret_version" "this" {
  secret_id = data.aws_secretsmanager_secret.this.id
}

data "archive_file" "this" {
  type = "zip"
  source_file = "${path.module}/sources/dummy.py"
  output_path = "${path.module}/sources/dummy.zip"
}