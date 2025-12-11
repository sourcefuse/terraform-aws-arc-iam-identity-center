# =============================================================================
# USER-FRIENDLY OUTPUTS - Easy to understand who has what access
# =============================================================================

#  SUMMARY DASHBOARD
output "access_summary_dashboard" {
  description = " Complete access summary - who has what permissions where"
  value = {
    " TOTAL_USERS"     = length(module.aws_sso.identity_store_users)
    " TOTAL_GROUPS"    = length(module.aws_sso.identity_store_groups)
    " PERMISSION_SETS" = length(module.aws_sso.permission_sets)
    " ASSIGNMENTS"     = length(module.aws_sso.account_assignments)
  }
}

#  USER DIRECTORY
# output "user_directory" {
#   description = "Complete user directory with contact information"
#   value = {
#     for user_key, user_info in module.aws_sso.identity_store_users : user_key => {
#       "Name"     = user_info.display_name
#       "Email"    = "${user_key}@company.com"
#       "User_ID"  = user_info.user_id
#       "Title"    = contains(keys(var), "user_titles") ? lookup(var.user_titles, user_key, "Employee") : "Employee"
#     }
#   }
# }

# GROUP MEMBERSHIP MATRIX
output "group_membership_matrix" {
  description = "Who belongs to which groups"
  value = {
    "Managers" = [
      for membership_key, membership in module.aws_sso.account_assignments :
      membership_key if can(regex("managers", lower(membership_key)))
    ]
    "Senior Developers" = [
      for membership_key, membership in module.aws_sso.account_assignments :
      membership_key if can(regex("senior.*dev", lower(membership_key)))
    ]
    "Junior Developers" = [
      for membership_key, membership in module.aws_sso.account_assignments :
      membership_key if can(regex("junior.*dev", lower(membership_key)))
    ]
    "Data Team" = [
      for membership_key, membership in module.aws_sso.account_assignments :
      membership_key if can(regex("data.*team", lower(membership_key)))
    ]
    "Finance Team" = [
      for membership_key, membership in module.aws_sso.account_assignments :
      membership_key if can(regex("finance", lower(membership_key)))
    ]
    "Support Team" = [
      for membership_key, membership in module.aws_sso.account_assignments :
      membership_key if can(regex("support", lower(membership_key)))
    ]
  }
}

# PERMISSION SETS GUIDE
output "permission_sets_guide" {
  description = "What each permission set allows users to do"
  value = {
    for ps_key, ps_info in module.aws_sso.permission_sets : ps_key => {
      "Description"      = ps_info.description
      "Session_Duration" = ps_info.session_duration
      "Use_Case"         = ps_key == "FullAdmin" ? "Emergency access only" : ps_key == "Developer" ? "Daily development work" : ps_key == "ReadOnly" ? "Safe viewing access" : ps_key == "BillingAccess" ? "Cost management" : ps_key == "SupportAccess" ? "Customer support" : "General access"
    }
  }
}

# ACCESS MATRIX - Who can access what
output "access_matrix" {
  description = "Complete access matrix showing who has access to which accounts"
  value = {
    "PRODUCTION_ACCESS" = {
      for assignment_key, assignment in module.aws_sso.account_assignments :
      assignment_key => {
        "Principal_Type" = assignment.principal_type
        "Permission_Set" = split("-", assignment_key)[0]
        "Access_Level"   = can(regex("admin", lower(assignment_key))) ? "FULL ADMIN" : can(regex("developer", lower(assignment_key))) ? "DEVELOPER" : can(regex("readonly", lower(assignment_key))) ? "READ ONLY" : can(regex("billing", lower(assignment_key))) ? "BILLING" : can(regex("support", lower(assignment_key))) ? "🎧 SUPPORT" : "❓ OTHER"
      }
      if assignment.target_id == var.production_account_id
    }

    "DEVELOPMENT_ACCESS" = {
      for assignment_key, assignment in module.aws_sso.account_assignments :
      assignment_key => {
        "Principal_Type" = assignment.principal_type
        "Permission_Set" = split("-", assignment_key)[0]
        "Access_Level"   = can(regex("admin", lower(assignment_key))) ? "FULL ADMIN" : can(regex("developer", lower(assignment_key))) ? "DEVELOPER" : can(regex("readonly", lower(assignment_key))) ? "READ ONLY" : can(regex("billing", lower(assignment_key))) ? "BILLING" : can(regex("support", lower(assignment_key))) ? "🎧 SUPPORT" : "❓ OTHER"
      }
      if assignment.target_id == var.development_account_id
    }
  }
}

# SECURITY ALERTS
output "security_alerts" {
  description = "Important security information and alerts"
  value = {
    "ADMIN_ACCESS_HOLDERS" = [
      for assignment_key, assignment in module.aws_sso.account_assignments :
      assignment_key if can(regex("admin", lower(assignment_key)))
    ]
    "SHORT_SESSION_PERMISSIONS" = [
      for ps_key, ps_info in module.aws_sso.permission_sets :
      ps_key if ps_info.session_duration == "PT2H"
    ]
    "SECURITY_RECOMMENDATIONS" = [
      "Review admin access regularly",
      "Admin sessions limited to 2 hours",
      "Developers have read-only prod access",
      "Junior developers limited to dev environment",
      "Monitor access patterns regularly"
    ]
  }
}

# QUICK REFERENCE GUIDE
output "quick_reference_guide" {
  description = "Quick reference for common tasks"
  value = {
    "TO_ADD_NEW_USER" = [
      "1. Add user to 'identity_store_users' section in main.tf",
      "2. Add user to appropriate group in 'group_memberships' section",
      "3. Run 'terraform plan' then 'terraform apply'"
    ]
    "TO_CHANGE_USER_PERMISSIONS" = [
      "1. Modify the user's group assignment in 'group_memberships'",
      "2. Or add individual assignment in 'account_assignments'",
      "3. Run 'terraform plan' then 'terraform apply'"
    ]
    "TO_REMOVE_USER" = [
      "1. Remove user from 'group_memberships' section",
      "2. Remove any individual assignments from 'account_assignments'",
      "3. Remove user from 'identity_store_users' section",
      "4. Run 'terraform plan' then 'terraform apply'"
    ]
    "TO_MODIFY_PERMISSIONS" = [
      "1. Edit the permission set in 'permission_sets' section",
      "2. Run 'terraform plan' then 'terraform apply'",
      "3. Note: Changes affect all users with that permission set"
    ]
  }
}

#  EMERGENCY CONTACTS
output "emergency_contacts" {
  description = "Emergency contacts for AWS access issues"
  value = {
    "AWS_ADMIN_CONTACTS" = [
      for user_key, user_info in module.aws_sso.identity_store_users :
      "${user_info.display_name} (${user_key}@company.com)"
      if can(regex("manager", lower(user_key)))
    ]
    "SUPPORT_CONTACTS" = [
      for user_key, user_info in module.aws_sso.identity_store_users :
      "${user_info.display_name} (${user_key}@company.com)"
      if can(regex("support", lower(user_key)))
    ]
  }
}
