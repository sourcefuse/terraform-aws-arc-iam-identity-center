variable "identity_center_instance_arn" {
  description = "ARN of existing Identity Center instance (optional - will auto-discover if not provided)"
  type        = string
  default     = null
}

variable "permission_sets" {
  description = "Map of permission sets to create"
  type = map(object({
    description          = optional(string, "")
    session_duration     = optional(string, "PT1H")
    relay_state          = optional(string)
    aws_managed_policies = optional(list(string), [])
    customer_managed_policies = optional(list(object({
      name = string
      path = optional(string, "/")
    })), [])
    inline_policy = optional(string)
    permissions_boundary = optional(object({
      customer_managed_policy_reference = optional(object({
        name = string
        path = optional(string, "/")
      }))
      managed_policy_arn = optional(string)
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "account_assignments" {
  description = "Map of account assignments to create"
  type = map(object({
    permission_set_name = string
    principal_type      = string
    principal_id        = string
    target_type         = string
    target_id           = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.account_assignments : contains(["USER", "GROUP"], v.principal_type)
    ])
    error_message = "principal_type must be either 'USER' or 'GROUP'."
  }

  validation {
    condition = alltrue([
      for k, v in var.account_assignments : contains(["AWS_ACCOUNT", "AWS_OU"], v.target_type)
    ])
    error_message = "target_type must be either 'AWS_ACCOUNT' or 'AWS_OU'."
  }
}

variable "identity_store_users" {
  description = "Map of Identity Store users to create"
  type = map(object({
    user_name    = string
    display_name = optional(string)
    given_name   = string
    family_name  = string
    email        = string
    locale       = optional(string, "en-US")
    nickname     = optional(string)
    timezone     = optional(string, "UTC")
    title        = optional(string)
    groups       = optional(list(string), [])
    direct_assignments = optional(list(object({
      permission_set = string
      account_id     = string
      reason         = optional(string, "")
    })), [])
  }))
  default = {}
}

variable "identity_store_groups" {
  description = "Map of Identity Store groups to create"
  type = map(object({
    display_name = string
    description  = optional(string, "")
  }))
  default = {}
}

variable "group_memberships" {
  description = "Map of group memberships to create"
  type = map(object({
    group_name = string
    user_name  = string
  }))
  default = {}
}

variable "applications" {
  description = "Map of applications to create"
  type = map(object({
    name                     = string
    description              = optional(string, "")
    application_provider_arn = string
    portal_options = optional(object({
      sign_in_options = optional(object({
        origin          = string
        application_url = optional(string)
      }))
      visibility = optional(string, "ENABLED")
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "application_assignments" {
  description = "Map of application assignments to create"
  type = map(object({
    application_name = string
    principal_type   = string
    principal_id     = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.application_assignments : contains(["USER", "GROUP"], v.principal_type)
    ])
    error_message = "principal_type must be either 'USER' or 'GROUP'."
  }
}

variable "tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default     = {}
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = ""
}

variable "name_suffix" {
  description = "Suffix for resource names"
  type        = string
  default     = ""
}
