# User Management Example

This example demonstrates comprehensive user and group management in AWS SSO, including both group-based and direct user assignments.

## What This Example Creates

### Users
- **john.doe** - Senior Developer (assigned to Developers group)
- **jane.smith** - DevOps Engineer (assigned to Developers group + direct prod access)
- **bob.wilson** - Business Analyst (assigned to BusinessUsers group)
- **alice.johnson** - System Administrator (direct admin access, no group)

### Groups
- **Developers** - Development team with dev environment access
- **BusinessUsers** - Business stakeholders with prod read-only access

### Assignment Patterns
1. **Group Assignments**: Users inherit permissions through group membership
2. **Direct User Assignments**: Individual users get specific permissions
3. **Mixed Assignments**: Users can have both group and direct assignments

## Prerequisites

- AWS Organizations enabled
- Existing AWS IAM Identity Center instance
- Two AWS accounts (production and development)
- AWS CLI configured with appropriate permissions

## Usage

1. Configure variables:
   ```bash
   terraform.tfvars
   # Edit with your actual values
   ```

2. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Key Features Demonstrated

- **User Creation**: Complete user profiles with names, emails, titles
- **Group Management**: Logical grouping of users by role/function
- **Group Memberships**: Assigning users to appropriate groups
- **Mixed Assignment Patterns**: Both group-based and direct user assignments
- **Multi-Account Access**: Different permission levels across environments

## Security Considerations

- **Principle of Least Privilege**: Users get minimum required access
- **Role Separation**: Different access patterns for different roles
- **Admin Access Control**: Admin access limited to specific users
- **Environment Isolation**: Different permissions for prod vs dev

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
| <a name="output_created_groups"></a> [created\_groups](#output\_created\_groups) | All created Identity Store groups |
| <a name="output_created_users"></a> [created\_users](#output\_created\_users) | All created Identity Store users |
| <a name="output_user_assignments_summary"></a> [user\_assignments\_summary](#output\_user\_assignments\_summary) | Summary of user and group assignments |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
