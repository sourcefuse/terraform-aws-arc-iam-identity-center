locals {
  # Identity Center instance configuration
  identity_center_instance_arn = var.identity_center_instance_arn != null ? var.identity_center_instance_arn : data.aws_ssoadmin_instances.existing[0].arns[0]
  identity_store_id            = data.aws_ssoadmin_instances.existing[0].identity_store_ids[0]

  # Naming convention
  name_prefix = var.name_prefix != "" ? "${var.name_prefix}-" : ""
  name_suffix = var.name_suffix != "" ? "-${var.name_suffix}" : ""

  # Common tags
  common_tags = merge(
    var.tags,
    {
      ManagedBy = "terraform"
      Module    = "aws-sso-identity-center"
    }
  )

  # Permission sets with computed names
  permission_sets_with_names = {
    for k, v in var.permission_sets : k => merge(v, {
      name = "${local.name_prefix}${k}${local.name_suffix}"
    })
  }

  # Account assignments with permission set ARNs and resolved principal IDs
  account_assignments_with_arns = {
    for k, v in local.all_account_assignments : k => merge(v, {
      permission_set_arn = aws_ssoadmin_permission_set.main[v.permission_set_name].arn
      resolved_principal_id = (
        v.principal_type == "GROUP" && contains(keys(var.identity_store_groups), v.principal_id) ?
        aws_identitystore_group.main[v.principal_id].group_id :
        v.principal_type == "USER" && contains(keys(var.identity_store_users), v.principal_id) ?
        aws_identitystore_user.main[v.principal_id].user_id :
        v.principal_id
      )
    })
  }

  # Group memberships with IDs
  group_memberships_with_ids = {
    for k, v in local.all_group_memberships : k => merge(v, {
      group_id = aws_identitystore_group.main[v.group_name].group_id
      user_id  = aws_identitystore_user.main[v.user_name].user_id
    })
  }

  # Group memberships generated from user definitions (new feature)
  generated_group_memberships = {
    for combo in flatten([
      for user_key, user_config in var.identity_store_users : [
        for group_name in lookup(user_config, "groups", []) : {
          key        = "${user_key}-to-${group_name}"
          user_name  = user_key
          group_name = group_name
        }
      ]
      ]) : combo.key => {
      user_name  = combo.user_name
      group_name = combo.group_name
    }
  }

  # Direct assignments generated from user definitions (new feature)
  generated_direct_assignments = {
    for combo in flatten([
      for user_key, user_config in var.identity_store_users : [
        for idx, assignment in lookup(user_config, "direct_assignments", []) : {
          key                 = "${user_key}-direct-${idx}"
          permission_set_name = assignment.permission_set
          principal_type      = "USER"
          principal_id        = user_key
          target_type         = "AWS_ACCOUNT"
          target_id           = assignment.account_id
        }
      ]
    ]) : combo.key => combo
  }

  # Combine generated and manual group memberships (backward compatible)
  all_group_memberships = merge(
    local.generated_group_memberships,
    var.group_memberships
  )

  # Combine generated and manual account assignments (backward compatible)
  all_account_assignments = merge(
    local.generated_direct_assignments,
    var.account_assignments
  )

  # Application assignments with IDs
  application_assignments_with_ids = {
    for k, v in var.application_assignments : k => merge(v, {
      application_arn = aws_ssoadmin_application.main[v.application_name].application_arn
      principal_id    = v.principal_type == "USER" ? aws_identitystore_user.main[v.principal_id].user_id : aws_identitystore_group.main[v.principal_id].group_id
    })
  }
}

# Data source for existing Identity Center instance
data "aws_ssoadmin_instances" "existing" {
  count = 1
}
