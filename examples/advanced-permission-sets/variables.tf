variable "production_account_id" {
  description = "AWS Account ID for production environment"
  type        = string
}

variable "development_account_id" {
  description = "AWS Account ID for development environment"
  type        = string
}

# variable "organization_root_ou_id" {
#   description = "Organization root OU ID for organization-wide access"
#   type        = string
# }

# variable "data_bucket_name" {
#   description = "Name of the S3 bucket for data science access"
#   type        = string
# }

# variable "cost_center" {
#   description = "Cost center for resource tagging"
#   type        = string
#   default     = "platform"
# }
