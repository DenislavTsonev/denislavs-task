resource "aws_secretsmanager_secret_version" "this" {
  secret_id = data.aws_secretsmanager_secret.this.id

  secret_string = jsonencode(local.updated_secret)

  depends_on = [ 
    module.db
  ]
}
