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
}
