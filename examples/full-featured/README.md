# Combined Advanced Example

This example combines comprehensive user management with advanced permission sets, demonstrating both group-based and direct user assignments with custom permission sets.

## What This Example Creates

### Users (5 total)
- **sarah.connor** - Senior Software Engineer → SeniorDevelopers group
- **john.smith** - Junior Developer → JuniorDevelopers group  
- **mike.johnson** - Engineering Team Lead → TeamLeads group + direct SeniorDeveloper access
- **lisa.davis** - External Consultant → Contractors group
- **alex.wilson** - DevOps Engineer → Direct SeniorDeveloper access (no group)

### Permission Sets (4 total)
- **SeniorDeveloper** - Full development access with boundary
- **JuniorDeveloper** - Limited development access with boundary
- **TeamLead** - Management access without boundary
- **Contractor** - Restricted external access with strict boundary

### Assignment Patterns
1. **Group Assignments** - Users inherit permissions through groups
2. **Direct User Assignments** - Individual users get specific access
3. **Mixed Assignments** - Users can have both group and direct assignments

## Prerequisites

**Required Customer Managed Policies:**

### Developer Policies (`/developers/` path):
- `DeveloperAdvancedAccess` - Advanced development permissions

### Management Policies (`/management/` path):  
- `TeamLeadAccess` - Team management and oversight permissions

### Boundary Policies (`/boundaries/` path):
- `DeveloperBoundary` - Maximum permissions for developers
- `ContractorBoundary` - Strict boundary for external contractors

### Example Policy Templates

#### DeveloperBoundary:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    },
    {
      "Effect": "Deny",
      "Action": [
        "iam:CreateUser",
        "iam:DeleteUser",
        "organizations:*",
        "account:*",
        "billing:*"
      ],
      "Resource": "*"
    }
  ]
}
```

#### ContractorBoundary:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket",
        "ec2:Describe*",
        "cloudwatch:Get*"
      ],
      "Resource": "*"
    }
  ]
}
```

## Usage

1. **Create required customer managed policies** (see above)
2. Copy and configure:
   ```bash
   terraform.tfvars
   # Edit with your values
   ```
3. Apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Key Features Demonstrated

### User Management
- **Complete user profiles** with names, emails, titles
- **Group memberships** for role-based access
- **Direct user assignments** for special cases
- **Mixed assignment patterns** (group + direct)

### Advanced Permission Sets  
- **All policy types** in single permission sets
- **Permission boundaries** for security governance
- **Role-based complexity** (different levels for different roles)
- **Session duration** optimization by role

### Real-World Scenarios
- **Team lead with dual access** (group + direct assignments)
- **DevOps engineer without group** (direct assignments only)
- **External contractor** with strict boundaries
- **Junior developer** with learning-focused permissions

## Security Highlights

- **Layered Security**: Multiple policy types working together
- **Principle of Least Privilege**: Role-appropriate permissions
- **Permission Boundaries**: Maximum permission enforcement
- **External User Controls**: Strict contractor limitations
- **Session Management**: Time-limited access by role

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_sso"></a> [aws\_sso](#module\_aws\_sso) | ../../ | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | sourcefuse/arc-tags/aws | 1.2.3 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_development_account_id"></a> [development\_account\_id](#input\_development\_account\_id) | AWS Account ID for development environment | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Name of the environment, i.e. dev, stage, prod | `string` | `"management"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace of the project, i.e. arc | `string` | `"arc"` | no |
| <a name="input_production_account_id"></a> [production\_account\_id](#input\_production\_account\_id) | AWS Account ID for production environment | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_complete_user_summary"></a> [complete\_user\_summary](#output\_complete\_user\_summary) | Complete summary of users, groups, and assignments |
| <a name="output_permission_sets_analysis"></a> [permission\_sets\_analysis](#output\_permission\_sets\_analysis) | Analysis of permission sets and their configurations |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
