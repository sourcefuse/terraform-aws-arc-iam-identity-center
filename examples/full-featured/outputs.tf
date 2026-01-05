output "complete_user_summary" {
  description = "Complete summary of users, groups, and assignments"
  value = {
    users_created = {
      for k, v in module.aws_sso.identity_store_users : k => {
        display_name = v.display_name
        user_id      = v.user_id
      }
    }
    groups_created = {
      for k, v in module.aws_sso.identity_store_groups : k => {
        display_name = v.display_name
        group_id     = v.group_id
      }
    }
    assignment_patterns = {
      group_assignments = [
        for k, v in module.aws_sso.account_assignments : k
        if can(regex("seniors|juniors|leads|contractors", k))
      ]
      direct_user_assignments = [
        for k, v in module.aws_sso.account_assignments : k
        if can(regex("alex|mike.*senior", k))
      ]
    }
  }
}

output "permission_sets_analysis" {
  description = "Analysis of permission sets and their configurations"
  value = {
    for k, v in module.aws_sso.permission_sets : k => {
      name             = v.name
      session_duration = v.session_duration
      has_boundary     = contains(["SeniorDeveloper", "JuniorDeveloper", "Contractor"], k)
      complexity_level = k == "TeamLead" ? "High" : k == "SeniorDeveloper" ? "Medium-High" : k == "JuniorDeveloper" ? "Medium" : "Low"
    }
  }
}
