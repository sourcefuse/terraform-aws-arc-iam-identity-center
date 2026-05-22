variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  type    = string
  default = "management"
}

variable "namespace" {
  type    = string
  default = "arc"
}

variable "keycloak_config" {
  description = "Keycloak connection and realm configuration"
  type = object({
    url       = string
    realm     = string
    client_id = string
    username  = string
    password  = string
    roles = optional(map(object({
      description = optional(string, "")
    })), {})
    groups = optional(map(object({
      roles = list(string)
    })), {})
  })
}

variable "management_account_id" {
  description = "AWS Account ID for the management account"
  type        = string
}

variable "development_account_id" {
  description = "AWS Account ID for the development account"
  type        = string
}
