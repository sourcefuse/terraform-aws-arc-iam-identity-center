module "aws_sso" {
  # source = "../../modules/aws-sso-identity-center"
  source = "../../"

  # Basic permission sets
  permission_sets = {
    "ReadOnlyAccess" = {
      description      = "Read-only access across AWS services"
      session_duration = "PT4H"
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/ReadOnlyAccess"
      ]
    }
    "PowerUserAccess" = {
      description      = "Power user access with limited IAM permissions"
      session_duration = "PT8H"
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/PowerUserAccess"
      ]
    }
  }

  # Create basic groups
  identity_store_groups = {
    "Developers" = {
      display_name = "Developers"
      description  = "Development team members"
    }
    "Viewers" = {
      display_name = "Viewers"
      description  = "Read-only access users"
    }
  }

  # Account assignments
  account_assignments = {
    "developers-poweruser" = {
      permission_set_name = "PowerUserAccess"
      principal_type      = "GROUP"
      principal_id        = "Developers"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.target_account_id
    }
    "viewers-readonly" = {
      permission_set_name = "ReadOnlyAccess"
      principal_type      = "GROUP"
      principal_id        = "Viewers"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.target_account_id
    }
  }

  # Common tags
  tags = {
    Environment = "development"
    Project     = "basic-sso"
    Owner       = "platform-team"
  }
}
