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

  # Advanced permission sets with all policy types
  permission_sets = {
    "FullStackDeveloper" = {
      description      = "Full-stack developer with comprehensive access"
      session_duration = "PT8H"

      # AWS Managed Policies
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/PowerUserAccess",
        "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
      ]

      # Customer Managed Policies
      customer_managed_policies = [
        {
          name = "DeveloperDatabaseAccess"
          path = "/developers/"
        },
        {
          name = "ApplicationDeploymentAccess"
          path = "/developers/"
        }
      ]

      # Inline Policy
      inline_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "lambda:CreateFunction",
              "lambda:UpdateFunctionCode",
              "lambda:InvokeFunction",
              "lambda:GetFunction",
              "lambda:ListFunctions"
            ]
            Resource = "arn:aws:lambda:*:*:function:dev-*"
          },
          {
            Effect = "Allow"
            Action = [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents"
            ]
            Resource = "arn:aws:logs:*:*:log-group:/aws/lambda/dev-*"
          }
        ]
      })

      # Permission Boundary (Customer Managed)
      permissions_boundary = {
        customer_managed_policy_reference = {
          name = "DeveloperBoundary"
          path = "/boundaries/"
        }
      }
    }

    "DataAnalyst" = {
      description      = "Data analyst with analytics and BI access"
      session_duration = "PT6H"

      # AWS Managed Policies
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/ReadOnlyAccess",
        "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
      ]

      # Customer Managed Policy
      customer_managed_policies = [
        {
          name = "DataWarehouseAccess"
          path = "/analytics/"
        }
      ]

      # Inline Policy for specific analytics tools
      inline_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "quicksight:*",
              "athena:*",
              "glue:GetTable",
              "glue:GetPartitions"
            ]
            Resource = "*"
          },
          {
            Effect = "Allow"
            Action = [
              "s3:GetObject",
              "s3:ListBucket"
            ]
            Resource = [
              "arn:aws:s3:::*",
              "arn:aws:s3:::*/*"
            ]
          }
        ]
      })

      # Permission Boundary (AWS Managed)
      permissions_boundary = {
        managed_policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
      }
    }

    "SecurityAuditor" = {
      description      = "Security auditor with compliance access"
      session_duration = "PT4H"

      # AWS Managed Policies
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/SecurityAudit",
        "arn:aws:iam::aws:policy/ReadOnlyAccess"
      ]

      # Customer Managed Policy
      customer_managed_policies = [
        {
          name = "ComplianceReportingAccess"
          path = "/security/"
        }
      ]

      # Inline Policy for security tools
      inline_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "guardduty:Get*",
              "guardduty:List*",
              "securityhub:Get*",
              "securityhub:List*",
              "inspector:Describe*",
              "inspector:List*",
              "config:Get*",
              "config:List*",
              "config:Describe*"
            ]
            Resource = "*"
          },
          {
            Effect = "Allow"
            Action = [
              "cloudtrail:LookupEvents",
              "cloudtrail:GetTrailStatus"
            ]
            Resource = "*"
          }
        ]
      })

      # No permission boundary for security auditor
    }

    "LimitedIntern" = {
      description      = "Intern with very limited access and strict boundaries"
      session_duration = "PT2H"

      # Only basic read access
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/ReadOnlyAccess"
      ]

      # Inline Policy for specific learning resources
      inline_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "s3:GetObject",
              "s3:ListBucket"
            ]
            Resource = [
              "arn:aws:s3:::training-materials",
              "arn:aws:s3:::training-materials/*"
            ]
          },
          {
            Effect = "Allow"
            Action = [
              "ec2:DescribeInstances",
              "ec2:DescribeImages"
            ]
            Resource = "*"
            Condition = {
              StringEquals = {
                "aws:RequestedRegion" = "us-east-1"
              }
            }
          }
        ]
      })

      # Strict permission boundary
      permissions_boundary = {
        customer_managed_policy_reference = {
          name = "InternBoundary"
          path = "/boundaries/"
        }
      }
    }
  }

  # Groups for different roles
  identity_store_groups = {
    "Developers" = {
      display_name = "Full Stack Developers"
      description  = "Full-stack development team"
    }
    "Analysts" = {
      display_name = "Data Analysts"
      description  = "Business intelligence and data analysis team"
    }
    "Security" = {
      display_name = "Security Team"
      description  = "Security and compliance team"
    }
    "Interns" = {
      display_name = "Interns"
      description  = "Temporary interns and trainees"
    }
  }

  # Account assignments
  account_assignments = {
    "developers-dev" = {
      permission_set_name = "FullStackDeveloper"
      principal_type      = "GROUP"
      principal_id        = "Developers"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.development_account_id
    }
    "analysts-prod" = {
      permission_set_name = "DataAnalyst"
      principal_type      = "GROUP"
      principal_id        = "Analysts"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.production_account_id
    }
    "security-all-accounts" = {
      permission_set_name = "SecurityAuditor"
      principal_type      = "GROUP"
      principal_id        = "Security"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.production_account_id
    }
    "security-dev-account" = {
      permission_set_name = "SecurityAuditor"
      principal_type      = "GROUP"
      principal_id        = "Security"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.development_account_id
    }
    "interns-dev" = {
      permission_set_name = "LimitedIntern"
      principal_type      = "GROUP"
      principal_id        = "Interns"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.development_account_id
    }
  }

  tags = module.tags.tags
}
