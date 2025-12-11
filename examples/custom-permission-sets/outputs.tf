output "permission_sets_with_boundaries" {
  description = "Permission sets with their boundary configurations"
  value = {
    for k, v in module.aws_sso.permission_sets : k => {
      arn              = v.arn
      name             = v.name
      description      = v.description
      session_duration = v.session_duration
      has_boundary     = contains(["FullStackDeveloper", "DataAnalyst", "LimitedIntern"], k)
    }
  }
}

output "policy_types_summary" {
  description = "Summary of policy types used in each permission set"
  value = {
    FullStackDeveloper = {
      aws_managed_policies      = 2
      customer_managed_policies = 2
      inline_policy             = "Yes"
      permission_boundary       = "Customer Managed"
    }
    DataAnalyst = {
      aws_managed_policies      = 2
      customer_managed_policies = 1
      inline_policy             = "Yes"
      permission_boundary       = "AWS Managed"
    }
    SecurityAuditor = {
      aws_managed_policies      = 2
      customer_managed_policies = 1
      inline_policy             = "Yes"
      permission_boundary       = "None"
    }
    LimitedIntern = {
      aws_managed_policies      = 1
      customer_managed_policies = 0
      inline_policy             = "Yes"
      permission_boundary       = "Customer Managed"
    }
  }
}
