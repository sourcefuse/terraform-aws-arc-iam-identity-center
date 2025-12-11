output "permission_sets" {
  description = "Created permission sets"
  value       = module.aws_sso.permission_sets
}

output "identity_store_groups" {
  description = "Created Identity Store groups"
  value       = module.aws_sso.identity_store_groups
}

output "account_assignments" {
  description = "Created account assignments"
  value       = module.aws_sso.account_assignments
}
