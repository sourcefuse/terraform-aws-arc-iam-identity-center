variable "target_account_id" {
  description = "AWS Account ID to assign permissions to"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}