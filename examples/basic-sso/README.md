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

1. Configure variables file:
   ```bash
   terraform.tfvars
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
| <a name="input_environment"></a> [environment](#input\_environment) | Name of the environment, i.e. dev, stage, prod | `string` | `"management"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace of the project, i.e. arc | `string` | `"arc"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_target_account_id"></a> [target\_account\_id](#input\_target\_account\_id) | AWS Account ID to assign permissions to | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_assignments"></a> [account\_assignments](#output\_account\_assignments) | Created account assignments |
| <a name="output_identity_store_groups"></a> [identity\_store\_groups](#output\_identity\_store\_groups) | Created Identity Store groups |
| <a name="output_permission_sets"></a> [permission\_sets](#output\_permission\_sets) | Created permission sets |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
