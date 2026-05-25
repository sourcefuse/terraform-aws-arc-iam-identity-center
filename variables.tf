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



variable "keycloak_enabled" {
  description = "Set to true to enable Keycloak SAML integration with IAM Identity Center"
  type        = bool
  default     = false
}

variable "keycloak_config" {
  description = "Keycloak configuration for SAML integration. Required when keycloak_enabled = true."
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
    users = optional(map(object({
      email      = string
      first_name = string
      last_name  = string
      groups     = optional(list(string), [])
    })), {})
    saml = optional(object({
      # Name of the SAML client in Keycloak
      client_name = optional(string, "amazon-aws")
      # IdP-initiated SSO URL name (used to construct the IdP-initiated login URL)
      idp_initiated_sso_url_name = optional(string, "amazon-aws")
      # Signature algorithm for SAML assertions. AWS requires RSA_SHA256.
      signature_algorithm = optional(string, "RSA_SHA256")
      # NameID format. AWS IAM Identity Center requires email.
      name_id_format = optional(string, "email")
      # Force the configured NameID format regardless of what the SP requests
      force_name_id_format = optional(bool, true)
      # Sign the SAML document
      sign_documents = optional(bool, true)
      # Sign the SAML assertions
      sign_assertions = optional(bool, true)
      # Include AuthnStatement in assertions
      include_authn_statement = optional(bool, true)
      # Require the SP (AWS) to sign AuthnRequests — AWS does not sign them
      client_signature_required = optional(bool, false)
      # User property to use as RoleSessionName attribute (email recommended)
      role_session_name_property = optional(string, "email")
      # NameFormat for the RoleSessionName SAML attribute
      role_session_name_format = optional(string, "Basic")
      # Whether the initial user password is temporary (forces change on first login)
      initial_password_temporary = optional(bool, true)
      # Additional valid redirect URIs beyond the default ACS URLs
      extra_redirect_uris = optional(list(string), [])
    }), {})
  })
  default = null
}
