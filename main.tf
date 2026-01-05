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
