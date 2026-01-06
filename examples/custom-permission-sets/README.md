# Custom Permission Sets Example

This example demonstrates advanced permission sets using all available policy types including permission boundaries.

## What This Example Creates

### Permission Sets with All Policy Types

#### 1. FullStackDeveloper
- **AWS Managed**: PowerUserAccess, S3ReadOnlyAccess
- **Customer Managed**: DeveloperDatabaseAccess, ApplicationDeploymentAccess
- **Inline Policy**: Lambda and CloudWatch Logs access for dev resources
- **Permission Boundary**: Customer managed DeveloperBoundary policy

#### 2. DataAnalyst  
- **AWS Managed**: ReadOnlyAccess, S3ReadOnlyAccess
- **Customer Managed**: DataWarehouseAccess
- **Inline Policy**: QuickSight, Athena, Glue access + specific S3 bucket
- **Permission Boundary**: AWS managed PowerUserAccess policy

#### 3. SecurityAuditor
- **AWS Managed**: SecurityAudit, ReadOnlyAccess  
- **Customer Managed**: ComplianceReportingAccess
- **Inline Policy**: Security services (GuardDuty, SecurityHub, Inspector, Config, CloudTrail)
- **Permission Boundary**: None (full security access)

#### 4. LimitedIntern
- **AWS Managed**: ReadOnlyAccess only
- **Customer Managed**: None
- **Inline Policy**: Training materials S3 access + limited EC2 describe
- **Permission Boundary**: Customer managed InternBoundary policy (very restrictive)

## Prerequisites

**CRITICAL**: You must create these customer managed policies in your AWS accounts BEFORE applying:

### Required Customer Managed Policies

#### Developer Policies (`/developers/` path):
- `DeveloperDatabaseAccess` - Database access for developers
- `ApplicationDeploymentAccess` - Application deployment permissions

#### Analytics Policies (`/analytics/` path):
- `DataWarehouseAccess` - Data warehouse and ETL access

#### Security Policies (`/security/` path):
- `ComplianceReportingAccess` - Compliance reporting tools access

#### Boundary Policies (`/boundaries/` path):
- `DeveloperBoundary` - Maximum permissions for developers
- `InternBoundary` - Very restrictive boundary for interns

### Example Boundary Policies

#### DeveloperBoundary Policy:
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
        "iam:CreateRole",
        "iam:DeleteRole",
        "organizations:*",
        "account:*"
      ],
      "Resource": "*"
    }
  ]
}
```

#### InternBoundary Policy:
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
        "cloudwatch:Get*",
        "cloudwatch:List*"
      ],
      "Resource": "*"
    }
  ]
}
```

## Usage

1. **Create required customer managed policies** (see above)
2. Configure variables:
   ```bash
   terraform.tfvars
   # Edit with your actual values
   ```
3. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Permission Boundary Benefits

- **Security**: Limits maximum permissions regardless of attached policies
- **Compliance**: Ensures users cannot exceed organizational limits
- **Risk Mitigation**: Prevents privilege escalation
- **Governance**: Enforces organizational security policies

## Key Features Demonstrated

- **All Policy Types**: AWS managed, customer managed, inline, permission boundaries
- **Mixed Boundary Types**: Both AWS managed and customer managed boundaries
- **Role-Based Design**: Different permission patterns for different roles
- **Security Layers**: Multiple policy types working together
- **Conditional Access**: Region and resource-based conditions

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
| <a name="output_permission_sets_with_boundaries"></a> [permission\_sets\_with\_boundaries](#output\_permission\_sets\_with\_boundaries) | Permission sets with their boundary configurations |
| <a name="output_policy_types_summary"></a> [policy\_types\_summary](#output\_policy\_types\_summary) | Summary of policy types used in each permission set |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
