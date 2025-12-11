# Basic SSO Setup Example

This example demonstrates a simple AWS SSO configuration for a single account with basic permission sets and groups.

## What This Example Creates

- Two permission sets: `ReadOnlyAccess` and `PowerUserAccess`
- Two Identity Store groups: `Developers` and `Viewers`
- Account assignments mapping groups to permission sets for a single AWS account

## Prerequisites

- AWS Organizations enabled
- Existing AWS IAM Identity Center instance
- AWS CLI configured with appropriate permissions
- Terraform >= 1.3

## Usage

1. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your values:
   ```hcl
   identity_center_instance_arn = "arn:aws:sso:::instance/ssoins-your-instance-id"
   target_account_id           = "123456789012"
   ```

3. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| identity_center_instance_arn | ARN of existing Identity Center instance | string | yes |
| target_account_id | AWS Account ID to assign permissions to | string | yes |

## Outputs

| Name | Description |
|------|-------------|
| permission_sets | Created permission sets with their ARNs |
| identity_store_groups | Created Identity Store groups |
| account_assignments | Created account assignments |

## Clean Up

To remove all resources:
```bash
terraform destroy
```
