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
    users = optional(map(object({
      email      = string
      first_name = string
      last_name  = string
      groups     = optional(list(string), [])
    })), {})
    saml = optional(object({
      client_name                = optional(string, "amazon-aws")
      idp_initiated_sso_url_name = optional(string, "amazon-aws")
      signature_algorithm        = optional(string, "RSA_SHA256")
      name_id_format             = optional(string, "email")
      force_name_id_format       = optional(bool, true)
      sign_documents             = optional(bool, true)
      sign_assertions            = optional(bool, true)
      include_authn_statement    = optional(bool, true)
      client_signature_required  = optional(bool, false)
      role_session_name_property = optional(string, "email")
      role_session_name_format   = optional(string, "Basic")
      initial_password_temporary = optional(bool, true)
      extra_redirect_uris        = optional(list(string), [])
    }), {})
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
