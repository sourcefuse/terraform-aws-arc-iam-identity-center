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
## Module Identity Center
################################################################

module "aws_sso" {
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
  tags = module.tags.tags

}
