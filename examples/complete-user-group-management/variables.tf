################################################################################
## shared
################################################################################
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Name of the environment, i.e. dev, stage, prod"
  default     = "management"
}

variable "namespace" {
  type        = string
  default     = "arc"
  description = "Namespace of the project, i.e. arc"
}

variable "production_account_id" {
  description = "AWS Account ID for production environment"
  type        = string
}

variable "development_account_id" {
  description = "AWS Account ID for development environment"
  type        = string
}
