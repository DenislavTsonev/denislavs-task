output "service_arn" {
  description = "The Amazon Resource Name (ARN) of the service"
  value       = try(aws_apprunner_service.this.arn, null)
}

output "service_id" {
  description = "An alphanumeric ID that App Runner generated for this service. Unique within the AWS Region"
  value       = try(aws_apprunner_service.this.service_id, null)
}

output "service_url" {
  description = "A subdomain URL that App Runner generated for this service. You can use this URL to access your service web application"
  value       = try("https://${aws_apprunner_service.this.service_url}", null)
}

output "service_status" {
  description = "The current state of the App Runner service"
  value       = try(aws_apprunner_service.this.status, null)
}

output "build_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = try(aws_iam_role.build[0].arn, null)
}

output "tasks_iam_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the IAM role"
  value       = aws_iam_role.tasks.arn
}

output "vpc_ingress_connection_arn" {
  description = "The Amazon Resource Name (ARN) of the VPC Ingress Connection"
  value       = try(aws_apprunner_vpc_ingress_connection.this[0].arn, null)
}

output "vpc_ingress_connection_domain_name" {
  description = "The domain name associated with the VPC Ingress Connection resource"
  value       = try(aws_apprunner_vpc_ingress_connection.this[0].domain_name, null)
}

################################################################################
# VPC Connector
################################################################################

output "vpc_connector_arn" {
  description = "The Amazon Resource Name (ARN) of VPC connector"
  value       = try(aws_apprunner_vpc_connector.this[0].arn, null)
}

output "vpc_connector_status" {
  description = "The current state of the VPC connector. If the status of a connector revision is INACTIVE, it was deleted and can't be used. Inactive connector revisions are permanently removed some time after they are deleted"
  value       = try(aws_apprunner_vpc_connector.this[0].status, null)
}

output "vpc_connector_revision" {
  description = "The revision of VPC connector. It's unique among all the active connectors (\"Status\": \"ACTIVE\") that share the same Name"
  value       = try(aws_apprunner_vpc_connector.this[0].vpc_connector_revision, null)
}

output "auto_scaling_configurations" {
  description = "Map of attribute maps for all autoscaling configurations created"
  value       = aws_apprunner_auto_scaling_configuration_version.this
}
