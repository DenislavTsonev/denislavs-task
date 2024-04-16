variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# Service
################################################################################

variable "create_service" {
  description = "Determines whether the service will be created"
  type        = bool
  default     = true
}

variable "service_name" {
  description = "The name of the service"
  type        = string
  default     = ""
}

variable "auto_scaling_configuration_arn" {
  description = "ARN of an App Runner automatic scaling configuration resource that you want to associate with your service. If not provided, App Runner associates the latest revision of a default auto scaling configuration"
  type        = string
  default     = null
}

variable "encryption_configuration" {
  description = "The encryption configuration for the service"
  type        = any
  default     = {}
}

variable "health_check_configuration" {
  description = "The health check configuration for the service"
  type        = any
  default     = {}
}

variable "instance_configuration" {
  description = "The instance configuration for the service"
  type        = any
  default     = {}
}

variable "network_configuration" {
  description = "The network configuration for the service"
  type        = any
  default     = {}
}

variable "observability_configuration" {
  description = "The observability configuration for the service"
  type        = any
  default     = {}
}

variable "source_configuration" {
  description = "The source configuration for the service"
  type        = any
  default     = {}
}

variable "min_size" {
  type        = number
  description = "(Optional, Forces new resource) Minimal number of instances that App Runner provisions for your service."
  default     = null
}

variable "max_concurrency" {
  type        = number
  description = "(Optional, Forces new resource) Maximal number of concurrent requests that you want an instance to process. When the number of concurrent requests goes over this limit, App Runner scales up your service."
  default     = null
}

variable "max_size" {
  type        = number
  description = "(Optional, Forces new resource) Maximal number of instances that App Runner provisions for your service."
  default     = null
}
################################################################################
# IAM Role - build
################################################################################
variable "build_iam_role_path" {
  description = "IAM role path"
  type        = string
  default     = null
}

variable "build_iam_role_description" {
  description = "Description of the role"
  type        = string
  default     = null
}

variable "build_iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "build_iam_role_policies" {
  description = "IAM policies to attach to the IAM role"
  type        = list(string)
  default     = []
}

################################################################################
# IAM Role - tasks
################################################################################
variable "tasks_iam_role_path" {
  description = "IAM role path"
  type        = string
  default     = null
}

variable "tasks_iam_role_description" {
  description = "Description of the role"
  type        = string
  default     = null
}

variable "tasks_iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "tasks_iam_role_policies" {
  description = "IAM policies to attach to the IAM role"
  type        = list(string)
  default     = []
}


################################################################################
# VPC Ingress Configuration
################################################################################

variable "create_ingress_vpc_connection" {
  description = "Determines whether a VPC ingress configuration will be created"
  type        = bool
  default     = false
}

variable "ingress_vpc_id" {
  description = "The ID of the VPC that is used for the VPC ingress configuration"
  type        = string
  default     = ""
}

variable "ingress_vpc_endpoint_id" {
  description = "The ID of the VPC endpoint that is used for the VPC ingress configuration"
  type        = string
  default     = ""
}

################################################################################
# VPC Connector
################################################################################

variable "create_vpc_connector" {
  description = "Determines whether a VPC Connector will be created"
  type        = bool
  default     = false
}

variable "vpc_connector_subnets" {
  description = "The subnets to use for the VPC Connector"
  type        = list(string)
  default     = []
}

variable "vpc_connector_security_groups" {
  description = "The security groups to use for the VPC Connector"
  type        = list(string)
  default     = []
}
