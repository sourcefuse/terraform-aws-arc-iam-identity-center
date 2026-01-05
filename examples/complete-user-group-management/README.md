# Complete AWS SSO Management

This example provides the most user-friendly way to manage AWS SSO with clear structure, emojis, and comprehensive outputs that make it easy to understand and modify user permissions.

##  What Makes This User-Friendly?

###  **Clear Visual Structure**
-  **Emojis and sections** - Easy to find what you need
-  **Descriptive names** - No cryptic codes or abbreviations  
-  **Organized sections** - Users, Groups, Permissions clearly separated
-  **Inline comments** - Explains what each section does

###  **Easy Management**
-  **Add users** - Just add to the users section
-  **Change permissions** - Modify group assignments
-  **Remove users** - Remove from relevant sections
-  **Group management** - Clear group structure by department

###  **Comprehensive Outputs**
-  **Access matrix** - See who has access to what
-  **User directory** - Complete contact information
-  **Permission guide** - Understand what each permission does
-  **Security alerts** - Important security information

##  Current Team Structure

###  **Users (6 people)**
- **john.manager** - Engineering Manager (Full Admin)
- **alice.developer** - Senior Software Engineer (Developer + ReadOnly Prod)
- **bob.junior** - Junior Developer (ReadOnly Dev only)
- **carol.analyst** - Data Analyst (ReadOnly both environments)
- **david.finance** - Finance Manager (Billing access)
- **eve.support** - Technical Support (Support access)

###  **Groups (6 groups)**
- **Managers** - Full admin access
- **Senior Developers** - Developer access to dev, readonly to prod
- **Junior Developers** - Readonly access to dev only
- **Data Team** - Readonly access to both environments
- **Finance Team** - Billing access to both environments
- **Support Team** - Support access to both environments

###  **Permission Sets (5 levels)**
- **FullAdmin** - Complete AWS access (2hr sessions)
- **Developer** - Most resources except IAM (8hr sessions)
- **ReadOnly** - View all resources (12hr sessions)
- **BillingAccess** - Cost and billing info (4hr sessions)
- **SupportAccess** - Support cases + readonly (6hr sessions)

##  Quick Start

1. **Copy and configure:**
   ```bash
   terraform.tfvars
   # Edit with your actual AWS account IDs
   ```

2. **Apply:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

3. **View results:**
   ```bash
   terraform output access_summary_dashboard
   terraform output user_directory
   terraform output access_matrix
   ```

##  How to Make Changes

###  **Add a New User**

1. **Add to users section:**
   ```hcl
   "new.user" = {
     user_name    = "new.user"
     display_name = "New User"
     given_name   = "New"
     family_name  = "User"
     email        = "new.user@company.com"
     title        = "Software Engineer"
   }
   ```

2. **Assign to a group:**
   ```hcl
   "new-user-to-group" = {
     group_name = "SeniorDevelopers"  # Choose appropriate group
     user_name  = "new.user"
   }
   ```

3. **Apply changes:**
   ```bash
   terraform apply
   ```

###  **Change User Permissions**

**Option 1: Move to different group**
```hcl
# Change this:
"bob-to-junior-devs" = {
  group_name = "JuniorDevelopers"
  user_name  = "bob.junior"
}

# To this:
"bob-to-senior-devs" = {
  group_name = "SeniorDevelopers"
  user_name  = "bob.junior"
}
```

**Option 2: Add individual assignment**
```hcl
"bob-special-prod-access" = {
  permission_set_name = "Developer"
  principal_type      = "USER"
  principal_id        = "bob.junior"
  target_type         = "AWS_ACCOUNT"
  target_id          = var.production_account_id
}
```

###  **Remove a User**

1. Remove from group memberships
2. Remove any individual assignments  
3. Remove from users section
4. Run `terraform apply`

###  **Modify Permission Sets**

Edit the permission set definition and run `terraform apply`. **Note:** This affects all users with that permission set.

##  Understanding the Outputs

After applying, you'll get comprehensive outputs:

###  **Access Summary Dashboard**
```
access_summary_dashboard = {
  " TOTAL_USERS" = 6
  " TOTAL_GROUPS" = 6  
  " PERMISSION_SETS" = 5
  " ASSIGNMENTS" = 12
}
```

###  **Access Matrix**
Shows exactly who has access to which accounts with what permissions.

###  **Security Alerts**
Highlights important security information like who has admin access.

###  **Quick Reference Guide**
Step-by-step instructions for common tasks.

##  Security Best Practices

-  **Admin access** limited to managers only
-  **Admin sessions** limited to 2 hours
-  **Developers** get readonly prod access for troubleshooting
-  **Junior developers** limited to dev environment
-  **Regular reviews** of access patterns recommended

##  Perfect For

-  **New teams** setting up AWS SSO
-  **Non-technical managers** who need to understand access
-  **Regular access reviews** and audits
-  **Onboarding/offboarding** team members
-  **Compliance** and security documentation

This example prioritizes clarity and ease of use over advanced features, making it perfect for teams that want straightforward AWS SSO management!

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
| <a name="output_access_matrix"></a> [access\_matrix](#output\_access\_matrix) | Complete access matrix showing who has access to which accounts |
| <a name="output_access_summary_dashboard"></a> [access\_summary\_dashboard](#output\_access\_summary\_dashboard) | Complete access summary - who has what permissions where |
| <a name="output_emergency_contacts"></a> [emergency\_contacts](#output\_emergency\_contacts) | Emergency contacts for AWS access issues |
| <a name="output_group_membership_matrix"></a> [group\_membership\_matrix](#output\_group\_membership\_matrix) | Who belongs to which groups |
| <a name="output_permission_sets_guide"></a> [permission\_sets\_guide](#output\_permission\_sets\_guide) | What each permission set allows users to do |
| <a name="output_quick_reference_guide"></a> [quick\_reference\_guide](#output\_quick\_reference\_guide) | Quick reference for common tasks |
| <a name="output_security_alerts"></a> [security\_alerts](#output\_security\_alerts) | Important security information and alerts |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
