management_account_id  = "777459856220"
development_account_id = "384351444384"

keycloak_config = {
  url       = "https://keycloak.arc-poc.link"
  realm     = "aws-sso"
  client_id = "admin-cli"
  username  = "admin"
  password  = "KeycloakAdmin#2026!"

  roles = {
    "aws-admin"     = { description = "Maps to KeycloakAdminAccess permission set" }
    "aws-developer" = { description = "Maps to KeycloakDeveloperAccess permission set" }
    "aws-readonly"  = { description = "Maps to KeycloakReadOnlyAccess permission set" }
  }

  groups = {
    "aws-admins"     = { roles = ["aws-admin"] }
    "aws-developers" = { roles = ["aws-developer"] }
    "aws-viewers"    = { roles = ["aws-readonly"] }
  }

  # Optional: create users in Keycloak automatically
  # username = email (must match IAM Identity Store userName)
  users = {
    "arun" = {
      email      = "arun.sai@sourcefuse.com"
      first_name = "Arun"
      last_name  = "Sai"
      groups     = ["aws-admins"]
    }
  }
}
