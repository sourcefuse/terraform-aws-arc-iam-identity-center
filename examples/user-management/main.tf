################################################################
## defaults
################################################################
terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}


################################################################################
## Tags
################################################################################
module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.3"

  environment = var.environment
  project     = var.namespace

  extra_tags = {
    RepoName = "terraform-aws-arc-iam-identity-center"
  }
}

################################################################
## Module Identity Center User Management
################################################################

module "aws_sso" {

  source = "../../"

  # Basic permission sets for user assignments
  permission_sets = {
    "DeveloperAccess" = {
      description      = "Developer access with limited permissions"
      session_duration = "PT8H"
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/PowerUserAccess"
      ]
    }
    "ReadOnlyAccess" = {
      description      = "Read-only access across AWS services"
      session_duration = "PT4H"
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/ReadOnlyAccess"
      ]
    }
    "AdminAccess" = {
      description      = "Full administrative access"
      session_duration = "PT2H"
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/AdministratorAccess"
      ]
    }
  }

  # Create Identity Store users
  identity_store_users = {
    "john.doe" = {
      user_name    = "john.doe"
      display_name = "John Doe"
      given_name   = "John"
      family_name  = "Doe"
      email        = "manichintu008+ssojohn@gmail.com"
      title        = "Senior Developer"
    }
    "jane.smith" = {
      user_name    = "jane.smith"
      display_name = "Jane Smith"
      given_name   = "Jane"
      family_name  = "Smith"
      email        = "manichintu008+ssojane@gmail.com"
      title        = "DevOps Engineer"
    }
    "bob.wilson" = {
      user_name    = "bob.wilson"
      display_name = "Bob Wilson"
      given_name   = "Bob"
      family_name  = "Wilson"
      email        = "manichintu008+ssobob@gmail.com"
      title        = "Business Analyst"
    }
    "alice.johnson" = {
      user_name    = "alice.johnson"
      display_name = "Alice Johnson"
      given_name   = "Alice"
      family_name  = "Johnson"
      email        = "manichintu008+ssoalice@gmail.com"
      title        = "System Administrator"
    }
  }

  # Create groups
  identity_store_groups = {
    "Developers" = {
      display_name = "Development Team"
      description  = "Software developers and engineers"
    }
    "BusinessUsers" = {
      display_name = "Business Users"
      description  = "Business analysts and stakeholders"
    }
  }

  # Assign users to groups
  group_memberships = {
    "john-to-developers" = {
      group_name = "Developers"
      user_name  = "john.doe"
    }
    "jane-to-developers" = {
      group_name = "Developers"
      user_name  = "jane.smith"
    }
    "bob-to-business" = {
      group_name = "BusinessUsers"
      user_name  = "bob.wilson"
    }
  }

  # Account assignments - Mix of group and individual user assignments
  account_assignments = {
    # Group assignments
    "developers-dev-access" = {
      permission_set_name = "DeveloperAccess"
      principal_type      = "GROUP"
      principal_id        = "Developers"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.development_account_id
    }
    "business-readonly-access" = {
      permission_set_name = "ReadOnlyAccess"
      principal_type      = "GROUP"
      principal_id        = "BusinessUsers"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.production_account_id
    }

    # Direct user assignments (users NOT in groups)
    "alice-admin-prod" = {
      permission_set_name = "AdminAccess"
      principal_type      = "USER"
      principal_id        = "alice.johnson"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.production_account_id
    }
    "alice-admin-dev" = {
      permission_set_name = "AdminAccess"
      principal_type      = "USER"
      principal_id        = "alice.johnson"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.development_account_id
    }
    "jane-readonly-prod" = {
      permission_set_name = "ReadOnlyAccess"
      principal_type      = "USER"
      principal_id        = "jane.smith"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.production_account_id
    }
  }

  tags = module.tags.tags
}
