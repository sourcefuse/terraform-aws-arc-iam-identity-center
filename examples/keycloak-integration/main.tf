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
    keycloak = {
      source  = "keycloak/keycloak"
      version = ">= 4.5"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.0"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "keycloak" {
  client_id = var.keycloak_config.client_id
  username  = var.keycloak_config.username
  password  = var.keycloak_config.password
  url       = var.keycloak_config.url
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

################################################################################
## IAM Identity Center — with Keycloak integration enabled
##
## Note    — Store metadata in SSM Parameter Store
##           The Keycloak SAML metadata XML is saved as a SecureString so it can
##           be retrieved for the one-time identity source change in the AWS Console:
##           Settings → Change identity source → External IdP → upload XML.
################################################################################
module "aws_sso" {
  source = "../../"

  # Enable Keycloak — all resources in keycloak.tf are triggered by this flag
  keycloak_enabled = true
  keycloak_config  = var.keycloak_config

  permission_sets = {
    "KeycloakAdminAccess" = {
      description      = "Full admin access - maps to Keycloak aws-admin role"
      session_duration = "PT8H"
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/AdministratorAccess"
      ]
      tags = { KeycloakRole = "aws-admin" }
    }
    "KeycloakDeveloperAccess" = {
      description      = "Developer access - maps to Keycloak aws-developer role"
      session_duration = "PT8H"
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/PowerUserAccess"
      ]
      tags = { KeycloakRole = "aws-developer" }
    }
    "KeycloakReadOnlyAccess" = {
      description      = "Read-only access - maps to Keycloak aws-readonly role"
      session_duration = "PT4H"
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/ReadOnlyAccess"
      ]
      tags = { KeycloakRole = "aws-readonly" }
    }
  }

  identity_store_groups = {
    "KeycloakAdmins" = {
      display_name = "Keycloak Admins"
      description  = "Federated admins from Keycloak aws-admins group"
    }
    "KeycloakDevelopers" = {
      display_name = "Keycloak Developers"
      description  = "Federated developers from Keycloak aws-developers group"
    }
    "KeycloakViewers" = {
      display_name = "Keycloak Viewers"
      description  = "Federated viewers from Keycloak aws-viewers group"
    }
  }

  account_assignments = {
    "keycloak-admins-mgmt" = {
      permission_set_name = "KeycloakAdminAccess"
      principal_type      = "GROUP"
      principal_id        = "KeycloakAdmins"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.management_account_id
    }
    "keycloak-developers-dev" = {
      permission_set_name = "KeycloakDeveloperAccess"
      principal_type      = "GROUP"
      principal_id        = "KeycloakDevelopers"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.development_account_id
    }
    "keycloak-viewers-dev" = {
      permission_set_name = "KeycloakReadOnlyAccess"
      principal_type      = "GROUP"
      principal_id        = "KeycloakViewers"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.development_account_id
    }
    "keycloak-viewers-mgmt" = {
      permission_set_name = "KeycloakReadOnlyAccess"
      principal_type      = "GROUP"
      principal_id        = "KeycloakViewers"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.management_account_id
    }
  }

  tags = module.tags.tags
}
