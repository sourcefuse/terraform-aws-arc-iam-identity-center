# Advanced Permission Sets Example

This example demonstrates sophisticated permission sets using a combination of AWS managed policies, customer managed policies, and inline policies for specialized roles.

## What This Example Creates

- **4 Advanced Permission Sets** with mixed policy types:
  - `DataScientist` - ML/Analytics access with S3 and SageMaker permissions
  - `DevOpsEngineer` - Infrastructure management with EKS and Terraform access
  - `SecurityAnalyst` - Security monitoring with GuardDuty and SecurityHub access
  - `CostOptimizer` - Cost management and billing access
- **4 Specialized Groups** mapped to these roles
- **Account and OU-level assignments** for different access patterns

## Permission Set Details

### DataScientist
- **AWS Managed**: S3ReadOnly, SageMakerReadOnly
- **Customer Managed**: DataLakeAccess (custom policy)
- **Inline Policy**: SageMaker notebook management, specific S3 bucket access
- **Session Duration**: 12 hours (for long-running ML workloads)

### DevOpsEngineer
- **AWS Managed**: PowerUserAccess
- **Customer Managed**: EKSClusterAccess, TerraformStateAccess
- **Inline Policy**: IAM role management for EKS and Terraform
- **Session Duration**: 8 hours

### SecurityAnalyst
- **AWS Managed**: SecurityAudit, ReadOnlyAccess
- **Customer Managed**: SecurityToolsAccess
- **Inline Policy**: Full access to security services, CloudWatch Logs for security
- **Session Duration**: 6 hours

### CostOptimizer
- **AWS Managed**: ReadOnlyAccess
- **Inline Policy**: Cost Explorer, Budgets, Billing, Reserved Instances, Support
- **Session Duration**: 4 hours

## Prerequisites

- AWS Organizations enabled
- Existing AWS IAM Identity Center instance
- **Customer managed policies must exist**:
  - `/data-science/DataLakeAccess`
  - `/devops/EKSClusterAccess`
  - `/devops/TerraformStateAccess`
  - `/security/SecurityToolsAccess`
- AWS CLI configured with appropriate permissions
- Terraform >= 1.3

## Usage

1. **Create required customer managed policies** in your AWS accounts first
2. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. Edit `terraform.tfvars` with your values:
   ```hcl
   identity_center_instance_arn = "arn:aws:sso:::instance/ssoins-your-instance-id"
   production_account_id       = "111111111111"
   development_account_id      = "222222222222"
   organization_root_ou_id     = "ou-root-1234567890"
   data_bucket_name           = "your-data-lake-bucket"
   cost_center               = "your-cost-center"
   ```

4. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Customer Managed Policies Required

You need to create these policies in your AWS accounts before applying:

### DataLakeAccess Policy (`/data-science/DataLakeAccess`)
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Resource": "arn:aws:s3:::your-data-lake-*"
    }
  ]
}
```

### EKSClusterAccess Policy (`/devops/EKSClusterAccess`)
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "eks:*"
      ],
      "Resource": "*"
    }
  ]
}
```

## Security Considerations

- **Least Privilege**: Each role has minimal required permissions
- **Conditional Access**: Policies include conditions for region restrictions
- **Resource Restrictions**: Access limited to specific resource patterns
- **Session Durations**: Configured based on role requirements
- **Separation of Duties**: Different roles for different functions

## Clean Up

To remove all resources:
```bash
terraform destroy
```

**Note**: Customer managed policies are not managed by this module and must be cleaned up separately.

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

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_development_account_id"></a> [development\_account\_id](#input\_development\_account\_id) | AWS Account ID for development environment | `string` | n/a | yes |
| <a name="input_production_account_id"></a> [production\_account\_id](#input\_production\_account\_id) | AWS Account ID for production environment | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_permission_sets_details"></a> [permission\_sets\_details](#output\_permission\_sets\_details) | Detailed information about created permission sets |
| <a name="output_role_assignments_summary"></a> [role\_assignments\_summary](#output\_role\_assignments\_summary) | Summary of role-based assignments |
| <a name="output_specialized_groups"></a> [specialized\_groups](#output\_specialized\_groups) | Created specialized Identity Store groups |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- BEGIN_TF_DOCS -->
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

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_development_account_id"></a> [development\_account\_id](#input\_development\_account\_id) | AWS Account ID for development environment | `string` | n/a | yes |
| <a name="input_production_account_id"></a> [production\_account\_id](#input\_production\_account\_id) | AWS Account ID for production environment | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_permission_sets_details"></a> [permission\_sets\_details](#output\_permission\_sets\_details) | Detailed information about created permission sets |
| <a name="output_role_assignments_summary"></a> [role\_assignments\_summary](#output\_role\_assignments\_summary) | Summary of role-based assignments |
| <a name="output_specialized_groups"></a> [specialized\_groups](#output\_specialized\_groups) | Created specialized Identity Store groups |
<!-- END_TF_DOCS -->