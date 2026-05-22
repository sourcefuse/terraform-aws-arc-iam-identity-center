output "keycloak_saml_provider_arn" {
  description = "ARN of the AWS IAM SAML provider created for Keycloak"
  value       = module.aws_sso.keycloak_saml_provider_arn
}

output "keycloak_saml_metadata_ssm_parameter" {
  description = "SSM parameter path storing the Keycloak SAML metadata XML. Retrieve this and upload to IAM Identity Center: Settings → Authentication → External IdP"
  value       = module.aws_sso.keycloak_saml_metadata_ssm_parameter
}

output "permission_sets" {
  description = "Created IAM Identity Center permission sets"
  value       = module.aws_sso.permission_sets
}

output "identity_store_groups" {
  description = "Created IAM Identity Center groups"
  value       = module.aws_sso.identity_store_groups
}

output "account_assignments" {
  description = "Account assignments"
  value       = module.aws_sso.account_assignments
}
