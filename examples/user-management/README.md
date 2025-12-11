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

## Architecture

```
Users:
├── john.doe ──────┐
├── jane.smith ────┼──► Developers Group ──► DeveloperAccess (Dev Account)
│                  │
├── bob.wilson ────┼──► BusinessUsers Group ──► ReadOnlyAccess (Prod Account)
│                  │
└── alice.johnson ─┼──► Direct AdminAccess (Prod + Dev Accounts)
                   │
jane.smith ────────┼──► Direct ReadOnlyAccess (Prod Account)
```

## Prerequisites

- AWS Organizations enabled
- Existing AWS IAM Identity Center instance
- Two AWS accounts (production and development)
- AWS CLI configured with appropriate permissions

## Usage

1. Copy and configure variables:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
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
