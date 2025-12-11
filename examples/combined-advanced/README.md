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

## Architecture Diagram

```
Users & Groups:
├── sarah.connor ──► SeniorDevelopers ──► SeniorDeveloper (Dev + Prod)
├── john.smith ───► JuniorDevelopers ──► JuniorDeveloper (Dev only)
├── mike.johnson ─► TeamLeads ────────► TeamLead (Dev + Prod)
│                └─► Direct ──────────► SeniorDeveloper (Dev)
├── lisa.davis ───► Contractors ─────► Contractor (Dev only)
└── alex.wilson ──► Direct ──────────► SeniorDeveloper (Dev + Prod)

Permission Sets Policy Composition:
├── SeniorDeveloper: AWS Managed + Customer Managed + Inline + Boundary
├── JuniorDeveloper: AWS Managed + Inline + Boundary  
├── TeamLead: AWS Managed + Customer Managed + Inline
└── Contractor: AWS Managed + Inline + Boundary
```

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
   cp terraform.tfvars.example terraform.tfvars
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
