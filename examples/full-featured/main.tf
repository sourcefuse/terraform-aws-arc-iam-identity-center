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


################################################################
## Module Identity Center
################################################################

module "aws_sso" {
  source = "../../"

  # Advanced permission sets with all policy types
  permission_sets = {
    "SeniorDeveloper" = {
      description      = "Senior developer with comprehensive access"
      session_duration = "PT8H"
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/PowerUserAccess"
      ]
      customer_managed_policies = [
        {
          name = "DeveloperAdvancedAccess"
          path = "/developers/"
        }
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
      permissions_boundary = {
        customer_managed_policy_reference = {
          name = "DeveloperBoundary"
          path = "/boundaries/"
        }
      }
    }

    "JuniorDeveloper" = {
      description      = "Junior developer with limited access"
      session_duration = "PT6H"
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/ReadOnlyAccess"
      ]
      inline_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "s3:GetObject",
              "s3:PutObject"
            ]
            Resource = "arn:aws:s3:::dev-sandbox/*"
          }
        ]
      })
      permissions_boundary = {
        managed_policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
      }
    }

    "TeamLead" = {
      description      = "Team lead with management access"
      session_duration = "PT8H"
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/PowerUserAccess"
      ]
      customer_managed_policies = [
        {
          name = "TeamLeadAccess"
          path = "/management/"
        }
      ]
      inline_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "iam:CreateRole",
              "iam:AttachRolePolicy",
              "iam:PassRole"
            ]
            Resource = "arn:aws:iam::*:role/team-*"
          }
        ]
      })
    }

    "Contractor" = {
      description      = "External contractor with time-limited access"
      session_duration = "PT4H"
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/ReadOnlyAccess"
      ]
      inline_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "s3:GetObject"
            ]
            Resource = "arn:aws:s3:::contractor-resources/*"
          }
        ]
      })
      permissions_boundary = {
        customer_managed_policy_reference = {
          name = "ContractorBoundary"
          path = "/boundaries/"
        }
      }
    }
  }

  # Create users with detailed profiles
  identity_store_users = {
    "sarah.connor" = {
      user_name    = "sarah.connor"
      display_name = "Sarah Connor"
      given_name   = "Sarah"
      family_name  = "Connor"
      email        = "manichintu008+ssosarah@gmail.com"
      title        = "Senior Software Engineer"
    }
    "john.smith" = {
      user_name    = "john.smith"
      display_name = "John Smith"
      given_name   = "John"
      family_name  = "Smith"
      email        = "manichintu008+ssojohn@gmail.com"
      title        = "Junior Developer"
    }
    "mike.johnson" = {
      user_name    = "mike.johnson"
      display_name = "Mike Johnson"
      given_name   = "Mike"
      family_name  = "Johnson"
      email        = "manichintu008+ssomike@gmail.com"
      title        = "Engineering Team Lead"
    }
    "lisa.davis" = {
      user_name    = "lisa.davis"
      display_name = "Lisa Davis"
      given_name   = "Lisa"
      family_name  = "Davis"
      email        = "manichintu008+ssolisa@gmail.com"
      title        = "External Consultant"
    }
    "alex.wilson" = {
      user_name    = "alex.wilson"
      display_name = "Alex Wilson"
      given_name   = "Alex"
      family_name  = "Wilson"
      email        = "manichintu008+ssoalex@gmail.com"
      title        = "DevOps Engineer"
    }
  }

  # Create groups
  identity_store_groups = {
    "SeniorDevelopers" = {
      display_name = "Senior Development Team"
      description  = "Experienced developers with advanced permissions"
    }
    "JuniorDevelopers" = {
      display_name = "Junior Development Team"
      description  = "New developers with learning permissions"
    }
    "TeamLeads" = {
      display_name = "Engineering Team Leads"
      description  = "Team leads with management responsibilities"
    }
    "Contractors" = {
      display_name = "External Contractors"
      description  = "External contractors and consultants"
    }
  }

  # Assign users to groups
  group_memberships = {
    "sarah-to-seniors" = {
      group_name = "SeniorDevelopers"
      user_name  = "sarah.connor"
    }
    "john-to-juniors" = {
      group_name = "JuniorDevelopers"
      user_name  = "john.smith"
    }
    "mike-to-leads" = {
      group_name = "TeamLeads"
      user_name  = "mike.johnson"
    }
    "lisa-to-contractors" = {
      group_name = "Contractors"
      user_name  = "lisa.davis"
    }
  }

  # Mixed assignment patterns
  account_assignments = {
    # Group-based assignments
    "seniors-dev-access" = {
      permission_set_name = "SeniorDeveloper"
      principal_type      = "GROUP"
      principal_id        = "SeniorDevelopers"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.development_account_id
    }
    "seniors-prod-access" = {
      permission_set_name = "SeniorDeveloper"
      principal_type      = "GROUP"
      principal_id        = "SeniorDevelopers"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.production_account_id
    }
    "juniors-dev-access" = {
      permission_set_name = "JuniorDeveloper"
      principal_type      = "GROUP"
      principal_id        = "JuniorDevelopers"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.development_account_id
    }
    "leads-all-access" = {
      permission_set_name = "TeamLead"
      principal_type      = "GROUP"
      principal_id        = "TeamLeads"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.production_account_id
    }
    "leads-dev-access" = {
      permission_set_name = "TeamLead"
      principal_type      = "GROUP"
      principal_id        = "TeamLeads"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.development_account_id
    }
    "contractors-limited" = {
      permission_set_name = "Contractor"
      principal_type      = "GROUP"
      principal_id        = "Contractors"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.development_account_id
    }

    # Direct user assignments (users not in groups or additional access)
    "alex-senior-dev" = {
      permission_set_name = "SeniorDeveloper"
      principal_type      = "USER"
      principal_id        = "alex.wilson"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.development_account_id
    }
    "alex-senior-prod" = {
      permission_set_name = "SeniorDeveloper"
      principal_type      = "USER"
      principal_id        = "alex.wilson"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.production_account_id
    }
    "mike-senior-access" = {
      permission_set_name = "SeniorDeveloper"
      principal_type      = "USER"
      principal_id        = "mike.johnson"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.development_account_id
    }
  }

  tags = {
    Environment = "multi-account"
    Project     = "combined-advanced"
    Owner       = "platform-team"
  }
}
