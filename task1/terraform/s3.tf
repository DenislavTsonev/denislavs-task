module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.1"

  bucket = "app-runner-bucket"
}