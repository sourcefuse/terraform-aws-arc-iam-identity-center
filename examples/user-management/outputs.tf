output "created_users" {
  description = "All created Identity Store users"
  value       = module.aws_sso.identity_store_users
}

output "created_groups" {
  description = "All created Identity Store groups"
  value       = module.aws_sso.identity_store_groups
}

output "user_assignments_summary" {
  description = "Summary of user and group assignments"
  value = {
    group_assignments = [
      for k, v in module.aws_sso.account_assignments : k
      if can(regex("developers|business", k))
    ]
    direct_user_assignments = [
      for k, v in module.aws_sso.account_assignments : k
      if can(regex("alice|jane.*prod", k))
    ]
    total_users  = length(module.aws_sso.identity_store_users)
    total_groups = length(module.aws_sso.identity_store_groups)
  }
}
