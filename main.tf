# Permission Sets
resource "aws_ssoadmin_permission_set" "main" {
  for_each = local.permission_sets_with_names

  name             = each.value.name
  description      = each.value.description
  instance_arn     = local.identity_center_instance_arn
  session_duration = each.value.session_duration
  relay_state      = each.value.relay_state

  tags = merge(local.common_tags, each.value.tags)

  lifecycle {
    create_before_destroy = true
  }

}

# AWS Managed Policy Attachments
resource "aws_ssoadmin_managed_policy_attachment" "aws_managed" {
  for_each = {
    for combo in flatten([
      for ps_key, ps_value in var.permission_sets : [
        for policy_arn in ps_value.aws_managed_policies : {
          key            = "${ps_key}-${basename(policy_arn)}"
          permission_set = ps_key
          policy_arn     = policy_arn
        }
      ]
    ]) : combo.key => combo
  }

  instance_arn       = local.identity_center_instance_arn
  managed_policy_arn = each.value.policy_arn
  permission_set_arn = aws_ssoadmin_permission_set.main[each.value.permission_set].arn
}

# Customer Managed Policy Attachments
resource "aws_ssoadmin_customer_managed_policy_attachment" "customer_managed" {
  for_each = {
    for combo in flatten([
      for ps_key, ps_value in var.permission_sets : [
        for policy in ps_value.customer_managed_policies : {
          key            = "${ps_key}-${policy.name}"
          permission_set = ps_key
          policy_name    = policy.name
          policy_path    = policy.path
        }
      ]
    ]) : combo.key => combo
  }

  instance_arn       = local.identity_center_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.main[each.value.permission_set].arn

  customer_managed_policy_reference {
    name = each.value.policy_name
    path = each.value.policy_path
  }
}

# Inline Policy Attachments
resource "aws_ssoadmin_permission_set_inline_policy" "inline" {
  for_each = {
    for k, v in var.permission_sets : k => v
    if v.inline_policy != null
  }

  inline_policy      = each.value.inline_policy
  instance_arn       = local.identity_center_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.main[each.key].arn
}

# Permission Boundaries
resource "aws_ssoadmin_permissions_boundary_attachment" "boundary" {
  for_each = {
    for k, v in var.permission_sets : k => v
    if v.permissions_boundary != null
  }

  instance_arn       = local.identity_center_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.main[each.key].arn

  permissions_boundary {
    dynamic "customer_managed_policy_reference" {
      for_each = each.value.permissions_boundary.customer_managed_policy_reference != null ? [each.value.permissions_boundary.customer_managed_policy_reference] : []
      content {
        name = customer_managed_policy_reference.value.name
        path = customer_managed_policy_reference.value.path
      }
    }
    managed_policy_arn = each.value.permissions_boundary.managed_policy_arn
  }
}

# Account Assignments
resource "aws_ssoadmin_account_assignment" "main" {
  for_each = local.account_assignments_with_arns

  instance_arn       = local.identity_center_instance_arn
  permission_set_arn = each.value.permission_set_arn
  principal_id       = each.value.resolved_principal_id
  principal_type     = each.value.principal_type
  target_id          = each.value.target_id
  target_type        = each.value.target_type

  # Ensure all policy attachments are complete before creating assignments
  depends_on = [
    aws_ssoadmin_managed_policy_attachment.aws_managed,
    aws_ssoadmin_customer_managed_policy_attachment.customer_managed,
    aws_ssoadmin_permission_set_inline_policy.inline,
    aws_ssoadmin_permissions_boundary_attachment.boundary
  ]

  timeouts {
    create = "30m"
    delete = "90m"
  }
}

# Identity Store Users
resource "aws_identitystore_user" "main" {
  for_each = var.identity_store_users

  identity_store_id = local.identity_store_id
  user_name         = each.value.user_name
  display_name      = each.value.display_name

  name {
    given_name  = each.value.given_name
    family_name = each.value.family_name
  }

  emails {
    value   = each.value.email
    primary = true
    type    = "work"
  }

  locale   = each.value.locale
  nickname = each.value.nickname
  timezone = each.value.timezone
  title    = each.value.title
}

# Identity Store Groups
resource "aws_identitystore_group" "main" {
  for_each = var.identity_store_groups

  identity_store_id = local.identity_store_id
  display_name      = each.value.display_name
  description       = each.value.description
}

# Group Memberships
resource "aws_identitystore_group_membership" "main" {
  for_each = local.group_memberships_with_ids

  identity_store_id = local.identity_store_id
  group_id          = each.value.group_id
  member_id         = each.value.user_id
}

# Applications
resource "aws_ssoadmin_application" "main" {
  for_each = var.applications

  name                     = each.value.name
  description              = each.value.description
  application_provider_arn = each.value.application_provider_arn
  instance_arn             = local.identity_center_instance_arn

  dynamic "portal_options" {
    for_each = each.value.portal_options != null ? [each.value.portal_options] : []
    content {
      dynamic "sign_in_options" {
        for_each = portal_options.value.sign_in_options != null ? [portal_options.value.sign_in_options] : []
        content {
          origin          = sign_in_options.value.origin
          application_url = sign_in_options.value.application_url
        }
      }
      visibility = portal_options.value.visibility
    }
  }

  tags = merge(local.common_tags, each.value.tags)
}

# Application Assignments
resource "aws_ssoadmin_application_assignment" "main" {
  for_each = local.application_assignments_with_ids

  application_arn = each.value.application_arn
  principal_id    = each.value.principal_id
  principal_type  = each.value.principal_type
}


################################################################################
## Keycloak SAML Integration
## Only created when var.keycloak_enabled = true.
################################################################################

data "aws_region" "current" {}
locals {
  aws_region = data.aws_region.current.id
}

resource "keycloak_realm" "aws" {
  count   = var.keycloak_enabled ? 1 : 0
  realm   = var.keycloak_config.realm
  enabled = true
}

resource "keycloak_saml_client" "aws_sso" {
  count    = var.keycloak_enabled ? 1 : 0
  realm_id = keycloak_realm.aws[0].id

  client_id                 = "https://${local.aws_region}.signin.aws.amazon.com/platform/saml/${local.identity_store_id}"
  name                      = var.keycloak_config.saml.client_name
  sign_documents            = var.keycloak_config.saml.sign_documents
  sign_assertions           = var.keycloak_config.saml.sign_assertions
  include_authn_statement   = var.keycloak_config.saml.include_authn_statement
  client_signature_required = var.keycloak_config.saml.client_signature_required
  signature_algorithm       = var.keycloak_config.saml.signature_algorithm
  valid_redirect_uris = concat(
    [
      "https://${local.aws_region}.sso.signin.aws/platform/saml/acs/*",
      "https://${local.aws_region}.signin.aws/platform/saml/acs/*",
      "https://*.signin.aws/*",
      "https://*.awsapps.com/*",
    ],
    var.keycloak_config.saml.extra_redirect_uris
  )
  base_url                   = "https://${local.aws_region}.sso.signin.aws/platform/saml/acs/*"
  idp_initiated_sso_url_name = var.keycloak_config.saml.idp_initiated_sso_url_name
  name_id_format             = var.keycloak_config.saml.name_id_format
  force_name_id_format       = var.keycloak_config.saml.force_name_id_format
}

resource "keycloak_saml_user_property_protocol_mapper" "role_session_name" {
  count     = var.keycloak_enabled ? 1 : 0
  realm_id  = keycloak_realm.aws[0].id
  client_id = keycloak_saml_client.aws_sso[0].id
  name      = "RoleSessionName"

  user_property              = var.keycloak_config.saml.role_session_name_property
  saml_attribute_name        = "https://aws.amazon.com/SAML/Attributes/RoleSessionName"
  saml_attribute_name_format = var.keycloak_config.saml.role_session_name_format
}

resource "keycloak_role" "aws_roles" {
  for_each = var.keycloak_enabled ? var.keycloak_config.roles : {}

  realm_id    = keycloak_realm.aws[0].id
  name        = each.key
  description = each.value.description
}

resource "keycloak_group" "aws_groups" {
  for_each = var.keycloak_enabled ? var.keycloak_config.groups : {}

  realm_id = keycloak_realm.aws[0].id
  name     = each.key
}

resource "keycloak_group_roles" "aws_group_roles" {
  for_each = var.keycloak_enabled ? var.keycloak_config.groups : {}

  realm_id = keycloak_realm.aws[0].id
  group_id = keycloak_group.aws_groups[each.key].id
  role_ids = [for r in each.value.roles : keycloak_role.aws_roles[r].id]
}

# Creates Keycloak users and optionally assigns them to Keycloak groups.
# user_name must match the email — it is sent as the SAML NameID and must
# match the userName in IAM Identity Store.

resource "random_password" "keycloak_user" {
  for_each = var.keycloak_enabled ? var.keycloak_config.users : {}

  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+?"
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
}

resource "keycloak_user" "aws_users" {
  for_each = var.keycloak_enabled ? var.keycloak_config.users : {}

  realm_id       = keycloak_realm.aws[0].id
  username       = each.value.email
  email          = each.value.email
  first_name     = each.value.first_name
  last_name      = each.value.last_name
  email_verified = true
  enabled        = true

  initial_password {
    value     = random_password.keycloak_user[each.key].result
    temporary = var.keycloak_config.saml.initial_password_temporary
  }
}

# Stores each user's generated password in SSM so admins can retrieve it.
# Path: /iam-identity-center/keycloak/<realm>/users/<email>/password
resource "aws_ssm_parameter" "keycloak_user_password" {
  for_each = var.keycloak_enabled ? var.keycloak_config.users : {}

  name        = "/iam-identity-center/keycloak/${var.keycloak_config.realm}/users/${replace(each.value.email, "@", "_at_")}/password"
  description = "Initial password for Keycloak user ${each.value.email}"
  type        = "SecureString"
  value       = random_password.keycloak_user[each.key].result

  tags = local.common_tags
}

resource "keycloak_user_groups" "aws_user_groups" {
  for_each = {
    for k, v in(var.keycloak_enabled ? var.keycloak_config.users : {}) :
    k => v if length(v.groups) > 0
  }

  realm_id = keycloak_realm.aws[0].id
  user_id  = keycloak_user.aws_users[each.key].id
  group_ids = [
    for g in each.value.groups : keycloak_group.aws_groups[g].id
  ]
}

data "http" "keycloak_saml_metadata" {
  count = var.keycloak_enabled ? 1 : 0
  url   = "${var.keycloak_config.url}/realms/${var.keycloak_config.realm}/protocol/saml/descriptor"

  depends_on = [keycloak_saml_client.aws_sso]
}

resource "aws_iam_saml_provider" "keycloak" {
  count                  = var.keycloak_enabled ? 1 : 0
  name                   = "keycloak-${var.keycloak_config.realm}"
  saml_metadata_document = data.http.keycloak_saml_metadata[0].response_body

  tags = local.common_tags
}

resource "aws_ssm_parameter" "keycloak_saml_metadata" {
  count       = var.keycloak_enabled ? 1 : 0
  name        = "/iam-identity-center/keycloak/${var.keycloak_config.realm}/saml-metadata"
  description = "Keycloak SAML metadata XML for IAM Identity Center external IdP configuration"
  type        = "SecureString"
  value       = data.http.keycloak_saml_metadata[0].response_body

  tags = local.common_tags
}
