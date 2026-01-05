variable "production_account_id" {
  description = "AWS Account ID for production environment"
  type        = string
}

variable "development_account_id" {
  description = "AWS Account ID for development environment"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}