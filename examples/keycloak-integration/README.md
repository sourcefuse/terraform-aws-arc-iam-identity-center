# Keycloak Integration with AWS IAM Identity Center

This example automates the full Keycloak ↔ AWS IAM Identity Center SAML 2.0 federation using Terraform.

## What Terraform Manages

| Resource | Provider |
|---|---|
| Fetch AWS SP metadata | `http` |
| Create Keycloak realm | `keycloak` |
| Create Keycloak SAML client for AWS | `keycloak` |
| Add `RoleSessionName` SAML attribute mapper | `keycloak` |
| Create Keycloak roles and groups | `keycloak` |
| Fetch Keycloak SAML metadata | `http` |
| Register Keycloak as AWS IAM SAML provider | `aws` |
| Store Keycloak metadata in SSM | `aws` |
| Create IAM Identity Center permission sets | `aws` |
| Create IAM Identity Center groups | `aws` |
| Create account assignments | `aws` |

## Prerequisites

- Keycloak instance running and reachable from where Terraform runs (version 20+)
- Keycloak admin credentials
- AWS IAM Identity Center enabled in your AWS Organization management account
- AWS credentials with `sso-admin:*`, `identitystore:*`, `iam:CreateSAMLProvider`, `ssm:PutParameter` permissions

## Usage

### From the Terraform Registry (recommended)

```hcl
provider "keycloak" {
  url       = "https://keycloak.example.com"
  client_id = "admin-cli"
  username  = "admin"
  password  = var.keycloak_admin_password
}

module "aws_sso" {
  source  = "sourcefuse/arc-iam-identity-center/aws"
  version = "x.x.x"

  permission_sets        = { ... }
  identity_store_groups  = { ... }
  account_assignments    = { ... }
}

module "keycloak" {
  source  = "sourcefuse/arc-iam-identity-center/aws//modules/keycloak"
  version = "x.x.x"

  realm             = "aws-sso"
  keycloak_url      = "https://keycloak.example.com"
  identity_store_id = module.aws_sso.identity_store_id
  instance_arn      = module.aws_sso.identity_center_instance_arn
  roles             = { "aws-admin" = { description = "Admin role" } }
  groups            = { "aws-admins" = { roles = ["aws-admin"] } }
  tags              = {}
}
```

### From this example (local development)

1. Copy `terraform.tfvars` and fill in your values:

```hcl
management_account_id  = "123456789012"
development_account_id = "210987654321"

keycloak_config = {
  url       = "https://keycloak.example.com"
  realm     = "aws-sso"
  client_id = "admin-cli"
  username  = "admin"
  password  = "your-admin-password"
  ...
}
```

> **Security:** Do not commit real credentials. Use `TF_VAR_keycloak_config` or a secrets manager.

2. Run Terraform:

```bash
terraform init
terraform apply
```

3. **One manual step — switch IAM Identity Center identity source:**

   This cannot be automated via Terraform or AWS CLI. Do it once after `terraform apply`:

   a. Retrieve the Keycloak metadata XML from SSM:
   ```bash
   aws ssm get-parameter \
     --name "$(terraform output -raw keycloak_saml_metadata_ssm_parameter)" \
     --with-decryption \
     --query Parameter.Value \
     --output text > keycloak-metadata.xml
   ```

   b. In the AWS Console: **IAM Identity Center → Settings → Authentication → Configure → External identity provider**

   c. Upload `keycloak-metadata.xml` as the IdP SAML metadata and save.

## Important: User Setup

IAM Identity Center matches the SAML `NameID` (sent as `emailAddress` format) against the `userName` field in the Identity Store.

**Users must have `userName` set to their email address.** Example in Terraform:

```hcl
identity_store_users = {
  "alice" = {
    user_name    = "alice@example.com"   # must match email
    email        = "alice@example.com"
    given_name   = "Alice"
    family_name  = "Smith"
    groups       = ["KeycloakAdmins"]
  }
}
```

In Keycloak, the user's email must match this value — it is sent as both the `NameID` and `RoleSessionName` in the SAML assertion.

## Architecture

```
terraform apply
  ├── Keycloak Provider
  │     ├── keycloak_realm "aws-sso"
  │     ├── keycloak_saml_client
  │     │     ├── client_id  = https://<region>.signin.aws.amazon.com/platform/saml/<identity-store-id>
  │     │     ├── name_id_format = email  (sends user email as NameID)
  │     │     └── Mapper: RoleSessionName → user.email
  │     ├── keycloak_role: aws-admin, aws-developer, aws-readonly
  │     └── keycloak_group: aws-admins, aws-developers, aws-viewers
  │
  ├── HTTP Provider
  │     ├── Fetch AWS SP metadata → imported into keycloak_saml_client
  │     └── Fetch Keycloak SAML metadata → stored in SSM + aws_iam_saml_provider
  │
  └── AWS Provider
        ├── aws_iam_saml_provider "keycloak-<realm>"
        ├── aws_ssm_parameter (Keycloak metadata XML)
        └── module.aws_sso
              ├── Permission sets: KeycloakAdminAccess, KeycloakDeveloperAccess, KeycloakReadOnlyAccess
              ├── Groups: KeycloakAdmins, KeycloakDevelopers, KeycloakViewers
              └── Account assignments → management + development accounts
```

## SAML Configuration Details

| Setting | Value | Reason |
|---|---|---|
| `client_id` | `https://<region>.signin.aws.amazon.com/platform/saml/<identity-store-id>` | Must match the Issuer in AWS AuthnRequests |
| `name_id_format` | `email` | IAM Identity Center requires `emailAddress` format |
| `saml.signature.algorithm` | `RSA_SHA256` | AWS rejects SHA1-signed assertions |
| `saml.force.name.id.format` | `true` | Prevents Keycloak from overriding the format |
| `RoleSessionName` mapper | `user.email` | Identifies the session in CloudTrail |

## Outputs

| Name | Description |
|---|---|
| `keycloak_saml_provider_arn` | ARN of the AWS IAM SAML provider |
| `keycloak_saml_metadata_ssm_parameter` | SSM path to retrieve Keycloak metadata XML for the manual identity source step |
| `permission_sets` | Created IAM Identity Center permission sets |
| `identity_store_groups` | Created IAM Identity Center groups |
| `account_assignments` | Account assignments |

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_http"></a> [http](#requirement\_http) | >= 3.0 |
| <a name="requirement_keycloak"></a> [keycloak](#requirement\_keycloak) | >= 4.5 |

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
| <a name="input_development_account_id"></a> [development\_account\_id](#input\_development\_account\_id) | AWS Account ID for the development account | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | `"management"` | no |
| <a name="input_keycloak_config"></a> [keycloak\_config](#input\_keycloak\_config) | Keycloak connection and realm configuration | <pre>object({<br/>    url       = string<br/>    realm     = string<br/>    client_id = string<br/>    username  = string<br/>    password  = string<br/>    roles = optional(map(object({<br/>      description = optional(string, "")<br/>    })), {})<br/>    groups = optional(map(object({<br/>      roles = list(string)<br/>    })), {})<br/>  })</pre> | n/a | yes |
| <a name="input_management_account_id"></a> [management\_account\_id](#input\_management\_account\_id) | AWS Account ID for the management account | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | n/a | `string` | `"arc"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_assignments"></a> [account\_assignments](#output\_account\_assignments) | Account assignments |
| <a name="output_identity_store_groups"></a> [identity\_store\_groups](#output\_identity\_store\_groups) | Created IAM Identity Center groups |
| <a name="output_keycloak_saml_metadata_ssm_parameter"></a> [keycloak\_saml\_metadata\_ssm\_parameter](#output\_keycloak\_saml\_metadata\_ssm\_parameter) | SSM parameter path storing the Keycloak SAML metadata XML. Retrieve this and upload to IAM Identity Center: Settings → Authentication → External IdP |
| <a name="output_keycloak_saml_provider_arn"></a> [keycloak\_saml\_provider\_arn](#output\_keycloak\_saml\_provider\_arn) | ARN of the AWS IAM SAML provider created for Keycloak |
| <a name="output_permission_sets"></a> [permission\_sets](#output\_permission\_sets) | Created IAM Identity Center permission sets |
<!-- END_TF_DOCS -->
