output "identity_center_instance_arn" {
  description = "ARN of the Identity Center instance"
  value       = local.identity_center_instance_arn
}

output "identity_store_id" {
  description = "ID of the Identity Store"
  value       = local.identity_store_id
}

output "permission_sets" {
  description = "Map of created permission sets"
  value = {
    for k, v in aws_ssoadmin_permission_set.main : k => {
      arn              = v.arn
      name             = v.name
      description      = v.description
      session_duration = v.session_duration
    }
  }
}

output "account_assignments" {
  description = "Map of created account assignments"
  value = {
    for k, v in aws_ssoadmin_account_assignment.main : k => {
      id                 = v.id
      permission_set_arn = v.permission_set_arn
      principal_id       = v.principal_id
      principal_type     = v.principal_type
      target_id          = v.target_id
      target_type        = v.target_type
    }
  }
}

output "identity_store_users" {
  description = "Map of created Identity Store users"
  value = {
    for k, v in aws_identitystore_user.main : k => {
      user_id      = v.user_id
      user_name    = v.user_name
      display_name = v.display_name
    }
  }
}

output "identity_store_groups" {
  description = "Map of created Identity Store groups"
  value = {
    for k, v in aws_identitystore_group.main : k => {
      group_id     = v.group_id
      display_name = v.display_name
      description  = v.description
    }
  }
}

output "applications" {
  description = "Map of created applications"
  value = {
    for k, v in aws_ssoadmin_application.main : k => {
      application_arn = v.application_arn
      name            = v.name
      description     = v.description
    }
  }
}

output "application_assignments" {
  description = "Map of created application assignments"
  value = {
    for k, v in aws_ssoadmin_application_assignment.main : k => {
      application_arn = v.application_arn
      principal_id    = v.principal_id
      principal_type  = v.principal_type
    }
  }
}

output "keycloak_saml_provider_arn" {
  description = "ARN of the AWS IAM SAML provider created for Keycloak (null when keycloak_enabled = false)"
  value       = var.keycloak_enabled ? aws_iam_saml_provider.keycloak[0].arn : null
}

output "keycloak_saml_metadata_ssm_parameter" {
  description = "SSM parameter path storing the Keycloak SAML metadata XML (null when keycloak_enabled = false)"
  value       = var.keycloak_enabled ? aws_ssm_parameter.keycloak_saml_metadata[0].name : null
}

output "keycloak_identity_center_metadata" {
  description = <<-EOT
    Instructions to complete the one-time IAM Identity Center identity source setup:
    1. Retrieve the Keycloak SAML metadata XML:
       aws ssm get-parameter --name <keycloak_saml_metadata_ssm_parameter> --with-decryption --query Parameter.Value --output text > keycloak-metadata.xml
    2. In the AWS Console: IAM Identity Center → Settings → Authentication → Configure → External IdP
    3. Upload keycloak-metadata.xml as the IdP SAML metadata
    4. Ensure IAM Identity Store users have userName set to their email address (NameID format is emailAddress)
  EOT
  value       = var.keycloak_enabled ? "Retrieve metadata from SSM: ${aws_ssm_parameter.keycloak_saml_metadata[0].name}" : null
}
