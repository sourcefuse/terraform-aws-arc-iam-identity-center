# AWS IAM Identity Center (SSO) Terraform Module

A comprehensive, reusable Terraform module for provisioning and managing AWS IAM Identity Center (AWS SSO) resources following AWS and Terraform best practices.

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Requirements](#requirements)
- [Usage](#usage)
- [Examples](#examples)
- [Module Structure](#module-structure)
- [Contributing](#contributing)
- [License](#license)

## Features

- **Identity Center Management**: Create or reference existing Identity Center instances
- **Permission Sets**: Support for AWS managed, customer managed, and inline policies
- **Account Assignments**: Flexible user/group to account/OU assignments
- **Identity Store**: Optional user and group management
- **Application Assignments**: SAML/OIDC application integration
- **External IdP Integration**: Support for SCIM and external identity providers
- **Conditional Resources**: Smart resource creation based on input variables
- **AWS Best Practices**: Follows naming conventions, tagging, and least-privilege principles

## Architecture

The module manages the following AWS IAM Identity Center components:

```
┌─────────────────────────────────────────────────────────────┐
│                    AWS Organization                          │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              IAM Identity Center                        │ │
│  │  ┌─────────────────┐  ┌─────────────────┐              │ │
│  │  │ Permission Sets │  │ Identity Store  │              │ │
│  │  │ - AWS Managed   │  │ - Users         │              │ │
│  │  │ - Customer Mgd  │  │ - Groups        │              │ │
│  │  │ - Inline        │  └─────────────────┘              │ │
│  │  └─────────────────┘                                   │ │
│  │           │                                             │ │
│  │  ┌─────────────────┐  ┌─────────────────┐              │ │
│  │  │Account          │  │ Applications    │              │ │
│  │  │Assignments      │  │ - SAML/OIDC     │              │ │
│  │  └─────────────────┘  └─────────────────┘              │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3 |
| aws | >= 5.0 |

## Usage

### 🚀 Quick Start - Basic Setup

```hcl
module "aws_sso" {
  source = "path/to/this/module"

  # Identity Center Configuration (optional - auto-discovers if not provided)
  identity_center_instance_arn = "arn:aws:sso:::instance/ssoins-1234567890abcdef"

  # Permission Sets
  permission_sets = {
    "AdminAccess" = {
      description      = "Full administrative access"
      session_duration = "PT8H"
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/AdministratorAccess"
      ]
    }
    "ReadOnlyAccess" = {
      description      = "Read-only access across AWS services"
      session_duration = "PT4H"
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/ReadOnlyAccess"
      ]
    }
  }

  # Create Groups
  identity_store_groups = {
    "Admins" = {
      display_name = "Administrators"
      description  = "System administrators"
    }
    "Developers" = {
      display_name = "Developers"
      description  = "Development team"
    }
  }

  # Account Assignments
  account_assignments = {
    "admins-full-access" = {
      permission_set_name = "AdminAccess"
      principal_type      = "GROUP"
      principal_id        = "Admins"
      target_type         = "AWS_ACCOUNT"
      target_id          = "123456789012"
    }
    "devs-readonly" = {
      permission_set_name = "ReadOnlyAccess"
      principal_type      = "GROUP"
      principal_id        = "Developers"
      target_type         = "AWS_ACCOUNT"
      target_id          = "123456789012"
    }
  }

  tags = {
    Environment = "production"
    Project     = "identity-management"
    Owner       = "platform-team"
  }
}
```

### 🎯 Complete User, Group Management Setup (Recommended)

For the most intuitive experience, use our complete-user-group-management structure where everything about each user is defined in one place:

```hcl
module "aws_sso" {
  source = "path/to/this/module"

  identity_center_instance_arn = "arn:aws:sso:::instance/ssoins-1234567890abcdef"

  # Permission Sets with clear descriptions
  permission_sets = {
    "FullAdmin" = {
      description      = "FULL ADMIN - Complete AWS access (use with caution)"
      session_duration = "PT2H"
      aws_managed_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    }
    "Developer" = {
      description      = "DEVELOPER - Can create/modify most resources except IAM"
      session_duration = "PT8H"
      aws_managed_policies = ["arn:aws:iam::aws:policy/PowerUserAccess"]
    }
    "ReadOnly" = {
      description      = "READ ONLY - Can view all resources but cannot modify"
      session_duration = "PT12H"
      aws_managed_policies = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
    }
  }

  # Users with groups and direct assignments in one place
  identity_store_users = {
    "john.manager" = {
      user_name    = "john.manager"
      display_name = "John Manager"
      given_name   = "John"
      family_name  = "Manager"
      email        = "john.manager@company.com"
      title        = "Engineering Manager"
      
      # Groups this user belongs to
      groups = ["Managers"]
      
      # Direct assignments (optional)
      direct_assignments = []
    }
    
    "alice.developer" = {
      user_name    = "alice.developer"
      display_name = "Alice Developer"
      given_name   = "Alice"
      family_name  = "Developer"
      email        = "alice.developer@company.com"
      title        = "Senior Software Engineer"
      
      # Groups this user belongs to
      groups = ["SeniorDevelopers"]
      
      # Additional direct access beyond group permissions
      direct_assignments = [
        {
          permission_set = "Developer"
          account_id     = "111111111111"  # Production account
          reason         = "Senior dev needs prod deployment access"
        }
      ]
    }
  }

  # Groups
  identity_store_groups = {
    "Managers" = {
      display_name = "Managers"
      description  = "Engineering and team managers"
    }
    "SeniorDevelopers" = {
      display_name = "Senior Developers"
      description  = "Experienced developers with advanced permissions"
    }
  }

  # Group-based account assignments
  account_assignments = {
    "managers-admin-prod" = {
      permission_set_name = "FullAdmin"
      principal_type      = "GROUP"
      principal_id        = "Managers"
      target_type         = "AWS_ACCOUNT"
      target_id          = "111111111111"
    }
    "senior-devs-dev-access" = {
      permission_set_name = "Developer"
      principal_type      = "GROUP"
      principal_id        = "SeniorDevelopers"
      target_type         = "AWS_ACCOUNT"
      target_id          = "222222222222"
    }
  }

  tags = {
    Environment = "multi-account"
    Project     = "arc"
    Owner       = "platform-team"
  }
}
```

### 🔧 Advanced Setup with Custom Policies

```hcl
module "aws_sso" {
  source = "path/to/this/module"

  identity_center_instance_arn = "arn:aws:sso:::instance/ssoins-1234567890abcdef"

  # Advanced permission sets with all policy types
  permission_sets = {
    "DataScientist" = {
      description      = "Data science and analytics access"
      session_duration = "PT12H"
      
      # AWS Managed Policies
      aws_managed_policies = [
        "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
        "arn:aws:iam::aws:policy/AmazonSageMakerReadOnly"
      ]
      
      # Customer Managed Policies (must exist in your account)
      customer_managed_policies = [
        {
          name = "DataLakeAccess"
          path = "/data-science/"
        }
      ]
      
      # Inline Policy for specific permissions
      inline_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "sagemaker:CreateNotebookInstance",
              "sagemaker:StartNotebookInstance"
            ]
            Resource = "*"
            Condition = {
              StringEquals = {
                "aws:RequestedRegion" = ["us-east-1", "us-west-2"]
              }
            }
          }
        ]
      })
      
      # Permission Boundary for security
      permissions_boundary = {
        customer_managed_policy_reference = {
          name = "DataScientistBoundary"
          path = "/boundaries/"
        }
      }
    }
  }

  # Rest of configuration...
  identity_store_groups = {
    "DataScience" = {
      display_name = "Data Science Team"
      description  = "Data scientists and ML engineers"
    }
  }

  account_assignments = {
    "datascience-prod" = {
      permission_set_name = "DataScientist"
      principal_type      = "GROUP"
      principal_id        = "DataScience"
      target_type         = "AWS_ACCOUNT"
      target_id          = "111111111111"
    }
  }

  tags = {
    Environment = "production"
    Project     = "advanced-sso"
    Owner       = "data-team"
  }
}
```

## Examples

The `examples/` directory contains several complete use cases:

- **[basic-sso-setup](examples/basic-sso-setup/)** - Simple SSO configuration for single account
- **[complete-user-group-management](examples/complete-user-group-management/)** - 🌟 **RECOMMENDED** - Easy-to-understand structure with comprehensive outputs
- **[organization-rbac](examples/organization-rbac/)** - Multi-account RBAC with multiple permission sets
- **[user-management](examples/user-management/)** - User creation, group assignments, and direct user assignments
- **[custom-permission-sets](examples/custom-permission-sets/)** - Advanced permission sets with all policy types and boundaries
- **[combined-advanced](examples/combined-advanced/)** - Complete example combining user management and custom permission sets
- **[external-idp-scim](examples/external-idp-scim/)** - External IdP integration with SCIM
- **[application-assignments](examples/application-assignments/)** - Custom SAML/OIDC applications
- **[advanced-permission-sets](examples/advanced-permission-sets/)** - Customer managed and inline policies


## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run validation: `make validate`
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
