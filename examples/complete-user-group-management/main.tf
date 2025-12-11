# =============================================================================
# AWS SSO USER-FRIENDLY MANAGEMENT EXAMPLE
# =============================================================================
# This example provides an easy-to-understand and modify structure for managing
# AWS SSO users, groups, permission sets, and assignments.
#
# QUICK REFERENCE:
# - To add a user: Add to 'users' section below
# - To add a group: Add to 'groups' section below  
# - To assign user to group: Add to 'user_group_assignments' section
# - To give account access: Add to 'account_access_assignments' section
# =============================================================================

module "aws_sso" {
  # source = "../../modules/aws-sso-identity-center"
  source = "../../"

  # =============================================================================
  # PERMISSION SETS - Define what users can do
  # =============================================================================
  permission_sets = {
    # Full Admin Access - Use carefully!
    "FullAdmin" = {
      description      = "FULL ADMIN - Complete AWS access (use with caution)"
      session_duration = "PT2H" # 2 hours max for security
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/AdministratorAccess"
      ]
    }

    # Developer Access - Good for development work
    "Developer" = {
      description      = "DEVELOPER - Can create/modify most resources except IAM"
      session_duration = "PT8H" # 8 hours for development work
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/PowerUserAccess"
      ]
      inline_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "iam:PassRole",
              "iam:ListRoles"
            ]
            Resource = "arn:aws:iam::*:role/app-*"
          }
        ]
      })
    }

    # Read Only Access - Safe for viewing
    "ReadOnly" = {
      description      = "READ ONLY - Can view all resources but cannot modify"
      session_duration = "PT12H" # 12 hours for monitoring/analysis
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/ReadOnlyAccess"
      ]
    }

    # Billing Access - For finance team
    "BillingAccess" = {
      description      = "BILLING - Can view costs and billing information"
      session_duration = "PT4H"
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/job-function/Billing"
      ]
    }

    # Support Access - For support team
    "SupportAccess" = {
      description      = "SUPPORT - Can create support cases and view resources"
      session_duration = "PT6H"
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/job-function/SupportUser",
        "arn:aws:iam::aws:policy/ReadOnlyAccess"
      ]
    }
  }

  # =============================================================================
  # USERS - Add your team members here with their groups and access
  # =============================================================================
  identity_store_users = {
    #  Management Team
    "john.manager" = {
      user_name    = "john.manager"
      display_name = "John Manager"
      given_name   = "John"
      family_name  = "Manager"
      email        = "john.manager@company.com"
      title        = "Engineering Manager"
      # 👥 Groups this user belongs to
      groups = ["Managers"]
      # 🎯 Direct account assignments (optional - leave empty if only using groups)
      direct_assignments = []
    }

    #  Development Team
    "alice.developer" = {
      user_name    = "alice.developer"
      display_name = "Alice Developer"
      given_name   = "Alice"
      family_name  = "Developer"
      email        = "alice.developer@company.com"
      title        = "Senior Software Engineer"
      # Groups this user belongs to
      groups = ["SeniorDevelopers"]
      # Direct account assignments (additional access beyond group)
      direct_assignments = [
        {
          permission_set = "Developer"
          account_id     = var.production_account_id
          reason         = "Senior dev needs prod deployment access"
        }
      ]
    }

    "bob.junior" = {
      user_name    = "bob.junior"
      display_name = "Bob Junior"
      given_name   = "Bob"
      family_name  = "Junior"
      email        = "bob.junior@company.com"
      title        = "Junior Developer"
      # Groups this user belongs to
      groups = ["JuniorDevelopers"]
      # Direct account assignments (none - only group access)
      direct_assignments = []
    }

    # Data Team
    "carol.analyst" = {
      user_name    = "carol.analyst"
      display_name = "Carol Analyst"
      given_name   = "Carol"
      family_name  = "Analyst"
      email        = "carol.analyst@company.com"
      title        = "Data Analyst"
      # Groups this user belongs to
      groups = ["DataTeam"]
      # Direct account assignments (none - only group access)
      direct_assignments = []
    }

    # Finance Team
    "david.finance" = {
      user_name    = "david.finance"
      display_name = "David Finance"
      given_name   = "David"
      family_name  = "Finance"
      email        = "david.finance@company.com"
      title        = "Finance Manager"
      # Groups this user belongs to
      groups = ["FinanceTeam"]
      # Direct account assignments (none - only group access)
      direct_assignments = []
    }

    # Support Team
    "eve.support" = {
      user_name    = "eve.support"
      display_name = "Eve Support"
      given_name   = "Eve"
      family_name  = "Support"
      email        = "eve.support@company.com"
      title        = "Technical Support"
      # Groups this user belongs to
      groups = ["SupportTeam"]
      # Direct account assignments (none - only group access)
      direct_assignments = []
    }

    # Special Case: User with NO group but direct assignments
    "temp.contractor" = {
      user_name    = "temp.contractor"
      display_name = "Temp Contractor"
      given_name   = "Temp"
      family_name  = "Contractor"
      email        = "temp.contractor@company.com"
      title        = "Temporary Contractor"
      # Groups this user belongs to (none)
      groups = []
      # Direct account assignments (only way this user gets access)
      direct_assignments = [
        {
          permission_set = "ReadOnly"
          account_id     = var.development_account_id
          reason         = "Temporary contractor - dev readonly only"
        }
      ]
    }
  }

  # =============================================================================
  # GROUPS - Organize users by role/department
  # =============================================================================
  identity_store_groups = {
    # Management Groups
    "Managers" = {
      display_name = "Managers"
      description  = "Engineering and team managers"
    }

    # Development Groups
    "SeniorDevelopers" = {
      display_name = "Senior Developers"
      description  = "Experienced developers with advanced permissions"
    }

    "JuniorDevelopers" = {
      display_name = "Junior Developers"
      description  = "New developers with limited permissions"
    }

    # Data Groups
    "DataTeam" = {
      display_name = "Data Team"
      description  = "Data analysts and scientists"
    }

    # Finance Groups
    "FinanceTeam" = {
      display_name = "Finance Team"
      description  = "Finance and billing team"
    }

    # Support Groups
    "SupportTeam" = {
      display_name = "Support Team"
      description  = "Technical support team"
    }
  }

  # =============================================================================
  # USER → GROUP ASSIGNMENTS - Auto-generated from user definitions above
  # =============================================================================
  # No need to define group_memberships - they're automatically created from 
  # the 'groups' field in each user definition above!

  # =============================================================================
  # ACCOUNT ACCESS ASSIGNMENTS - Group-based + auto-generated direct assignments
  # =============================================================================
  account_assignments = {
    # MANAGERS - Full admin access to both environments
    "managers-admin-prod" = {
      permission_set_name = "FullAdmin"
      principal_type      = "GROUP"
      principal_id        = "Managers"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.production_account_id
    }

    "managers-admin-dev" = {
      permission_set_name = "FullAdmin"
      principal_type      = "GROUP"
      principal_id        = "Managers"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.development_account_id
    }

    #  SENIOR DEVELOPERS - Developer access to dev, read-only to prod (base access)
    "senior-devs-dev-access" = {
      permission_set_name = "Developer"
      principal_type      = "GROUP"
      principal_id        = "SeniorDevelopers"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.development_account_id
    }

    "senior-devs-prod-readonly" = {
      permission_set_name = "ReadOnly"
      principal_type      = "GROUP"
      principal_id        = "SeniorDevelopers"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.production_account_id
    }

    # JUNIOR DEVELOPERS - Read-only access to dev only
    "junior-devs-dev-readonly" = {
      permission_set_name = "ReadOnly"
      principal_type      = "GROUP"
      principal_id        = "JuniorDevelopers"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.development_account_id
    }

    # DATA TEAM - Read-only access to both environments
    "data-team-prod-readonly" = {
      permission_set_name = "ReadOnly"
      principal_type      = "GROUP"
      principal_id        = "DataTeam"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.production_account_id
    }

    "data-team-dev-readonly" = {
      permission_set_name = "ReadOnly"
      principal_type      = "GROUP"
      principal_id        = "DataTeam"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.development_account_id
    }

    # FINANCE TEAM - Billing access to both environments
    "finance-prod-billing" = {
      permission_set_name = "BillingAccess"
      principal_type      = "GROUP"
      principal_id        = "FinanceTeam"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.production_account_id
    }

    "finance-dev-billing" = {
      permission_set_name = "BillingAccess"
      principal_type      = "GROUP"
      principal_id        = "FinanceTeam"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.development_account_id
    }

    # SUPPORT TEAM - Support access to both environments
    "support-prod-access" = {
      permission_set_name = "SupportAccess"
      principal_type      = "GROUP"
      principal_id        = "SupportTeam"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.production_account_id
    }

    "support-dev-access" = {
      permission_set_name = "SupportAccess"
      principal_type      = "GROUP"
      principal_id        = "SupportTeam"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.development_account_id
    }

    # INDIVIDUAL DIRECT ASSIGNMENTS are auto-generated from user definitions above!
    # No need to define them here - they come from the 'direct_assignments' field
    # in each user definition.
  }

  # Common tags for all resources
  tags = {
    Environment = "multi-account"
    Project     = "user-friendly-sso"
    Owner       = "platform-team"
    ManagedBy   = "terraform"
  }
}
