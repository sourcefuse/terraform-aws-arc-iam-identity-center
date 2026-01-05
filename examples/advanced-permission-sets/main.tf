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

  # Advanced permission sets with different policy types
  permission_sets = {
    "DataScientist" = {
      description      = "Data science and analytics access"
      session_duration = "PT12H"
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
        "arn:aws:iam::aws:policy/AmazonSageMakerReadOnly"
      ]
      customer_managed_policies = [
        {
          name = "DataLakeAccess"
          path = "/data-science/"
        }
      ]
      inline_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "sagemaker:CreateNotebookInstance",
              "sagemaker:StartNotebookInstance",
              "sagemaker:StopNotebookInstance",
              "sagemaker:DeleteNotebookInstance"
            ]
            Resource = "*"
            Condition = {
              StringEquals = {
                "aws:RequestedRegion" = ["us-east-1", "us-west-2"]
              }
            }
          },
          {
            Effect = "Allow"
            Action = [
              "s3:GetObject",
              "s3:PutObject"
            ]
            Resource = "arn:aws:s3:::*/*"
          }
        ]
      })
    }
    "DevOpsEngineer" = {
      description      = "DevOps and infrastructure management"
      session_duration = "PT8H"
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/PowerUserAccess"
      ]
      customer_managed_policies = [
        {
          name = "EKSClusterAccess"
          path = "/devops/"
        },
        {
          name = "TerraformStateAccess"
          path = "/devops/"
        }
      ]
      inline_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "iam:CreateRole",
              "iam:DeleteRole",
              "iam:AttachRolePolicy",
              "iam:DetachRolePolicy",
              "iam:PutRolePolicy",
              "iam:DeleteRolePolicy",
              "iam:PassRole"
            ]
            Resource = [
              "arn:aws:iam::*:role/eks-*",
              "arn:aws:iam::*:role/terraform-*"
            ]
          }
        ]
      })
    }
    "SecurityAnalyst" = {
      description      = "Security monitoring and incident response"
      session_duration = "PT6H"
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/SecurityAudit",
        "arn:aws:iam::aws:policy/ReadOnlyAccess"
      ]
      customer_managed_policies = [
        {
          name = "SecurityToolsAccess"
          path = "/security/"
        }
      ]
      inline_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "guardduty:*",
              "securityhub:*",
              "inspector:*",
              "config:*"
            ]
            Resource = "*"
          },
          {
            Effect = "Allow"
            Action = [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents",
              "logs:DescribeLogGroups",
              "logs:DescribeLogStreams"
            ]
            Resource = "arn:aws:logs:*:*:log-group:/security/*"
          }
        ]
      })
    }
    "CostOptimizer" = {
      description      = "Cost management and optimization"
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
              "ce:*",
              "cur:*",
              "budgets:*",
              "aws-portal:ViewBilling",
              "aws-portal:ViewUsage"
            ]
            Resource = "*"
          },
          {
            Effect = "Allow"
            Action = [
              "ec2:DescribeReservedInstances",
              "ec2:DescribeReservedInstancesOfferings",
              "ec2:ModifyReservedInstances",
              "rds:DescribeReservedDBInstances",
              "rds:DescribeReservedDBInstancesOfferings"
            ]
            Resource = "*"
          },
          {
            Effect = "Allow"
            Action = [
              "support:*"
            ]
            Resource = "*"
          }
        ]
      })
    }
  }

  # Specialized groups for advanced roles
  identity_store_groups = {
    "DataScience" = {
      display_name = "Data Science Team"
      description  = "Data scientists and ML engineers"
    }
    "DevOps" = {
      display_name = "DevOps Engineers"
      description  = "Infrastructure and deployment engineers"
    }
    "SecurityAnalysts" = {
      display_name = "Security Analysts"
      description  = "Security monitoring and incident response team"
    }
    "FinOps" = {
      display_name = "Financial Operations"
      description  = "Cost optimization and financial management"
    }
  }

  # Account assignments for specialized roles
  account_assignments = {
    "datascience-prod" = {
      permission_set_name = "DataScientist"
      principal_type      = "GROUP"
      principal_id        = "DataScience"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.production_account_id
    }
    "datascience-dev" = {
      permission_set_name = "DataScientist"
      principal_type      = "GROUP"
      principal_id        = "DataScience"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.development_account_id
    }
    "devops-prod" = {
      permission_set_name = "DevOpsEngineer"
      principal_type      = "GROUP"
      principal_id        = "DevOps"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.production_account_id
    }
    "devops-dev" = {
      permission_set_name = "DevOpsEngineer"
      principal_type      = "GROUP"
      principal_id        = "DevOps"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.development_account_id
    }
    "security-all-accounts" = {
      permission_set_name = "SecurityAnalyst"
      principal_type      = "GROUP"
      principal_id        = "SecurityAnalysts"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.production_account_id
    }
    "security-dev-account" = {
      permission_set_name = "SecurityAnalyst"
      principal_type      = "GROUP"
      principal_id        = "SecurityAnalysts"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.development_account_id
    }
    "finops-prod-account" = {
      permission_set_name = "CostOptimizer"
      principal_type      = "GROUP"
      principal_id        = "FinOps"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.production_account_id
    }
    "finops-dev-account" = {
      permission_set_name = "CostOptimizer"
      principal_type      = "GROUP"
      principal_id        = "FinOps"
      target_type         = "AWS_ACCOUNT"
      target_id           = var.development_account_id
    }
  }

  # Tags for advanced permission sets
  tags = {
    Environment = "multi-account"
    Project     = "advanced-rbac"
    Owner       = "platform-team"
  }
}
