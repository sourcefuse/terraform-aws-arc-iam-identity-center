output "permission_sets_details" {
  description = "Detailed information about created permission sets"
  value = {
    for k, v in module.aws_sso.permission_sets : k => {
      arn              = v.arn
      name             = v.name
      description      = v.description
      session_duration = v.session_duration
    }
  }
}

output "specialized_groups" {
  description = "Created specialized Identity Store groups"
  value       = module.aws_sso.identity_store_groups
}

output "role_assignments_summary" {
  description = "Summary of role-based assignments"
  value = {
    data_science_assignments = [
      for k, v in module.aws_sso.account_assignments : k
      if can(regex("datascience", k))
    ]
    devops_assignments = [
      for k, v in module.aws_sso.account_assignments : k
      if can(regex("devops", k))
    ]
    security_assignments = [
      for k, v in module.aws_sso.account_assignments : k
      if can(regex("security", k))
    ]
    finops_assignments = [
      for k, v in module.aws_sso.account_assignments : k
      if can(regex("finops", k))
    ]
  }
}
