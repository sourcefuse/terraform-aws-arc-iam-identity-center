################################################################################
## Keycloak SAML Integration
## Only created when var.keycloak_enabled = true.
################################################################################

data "aws_region" "current" {}
locals {
  aws_region = data.aws_region.current.id
}

# Download the AWS IAM Identity Center SP metadata so Keycloak can import the
# ACS URL and signing certificate automatically when the SAML client is created.
data "http" "aws_sp_metadata" {
  count = var.keycloak_enabled ? 1 : 0
  url   = "https://signin.aws.amazon.com/saml-metadata/${data.aws_ssoadmin_instances.existing[0].arns[0]}"
}

# Dedicated Keycloak realm to isolate AWS SSO federation from other applications.
resource "keycloak_realm" "aws" {
  count   = var.keycloak_enabled ? 1 : 0
  realm   = var.keycloak_config.realm
  enabled = true
}

# Registers AWS IAM Identity Center as a SAML Service Provider inside Keycloak.
# The AWS SP metadata is imported so Keycloak knows the correct ACS URL and certificate.
resource "keycloak_saml_client" "aws_sso" {
  count    = var.keycloak_enabled ? 1 : 0
  realm_id = keycloak_realm.aws[0].id

  # client_id must match the Issuer URL that IAM Identity Center sends in SAML AuthnRequests.
  # Format: https://<region>.signin.aws.amazon.com/platform/saml/<identity-store-id>
  client_id                 = "https://${local.aws_region}.signin.aws.amazon.com/platform/saml/${local.identity_store_id}"
  name                      = "amazon-aws"
  sign_documents            = true
  sign_assertions           = true
  include_authn_statement   = true
  client_signature_required = false
  # RSA_SHA256 required — AWS rejects SHA1-signed assertions
  signature_algorithm = "RSA_SHA256"
  valid_redirect_uris = [
    "https://${local.aws_region}.sso.signin.aws/platform/saml/acs/*",
    "https://*.awsapps.com/*"
  ]
  base_url                   = "https://${local.aws_region}.sso.signin.aws/platform/saml/acs/*"
  idp_initiated_sso_url_name = "amazon-aws"

  # IAM Identity Center requires emailAddress NameID format.
  # The NameID value must match the userName in IAM Identity Store.
  # Users must have userName set to their email address.
  name_id_format = "email"

  extra_config = {
    "saml.sp.metadata" = data.http.aws_sp_metadata[0].response_body
    # Prevents Keycloak from overriding the NameID format
    "saml.force.name.id.format" = "true"
  }
}

# Sends the authenticated user's username as the AWS session name in the SAML assertion.
# Must match the username in IAM Identity Store.
resource "keycloak_saml_user_property_protocol_mapper" "role_session_name" {
  count     = var.keycloak_enabled ? 1 : 0
  realm_id  = keycloak_realm.aws[0].id
  client_id = keycloak_saml_client.aws_sso[0].id
  name      = "RoleSessionName"

  # Use email so the session name matches the NameID (also email)
  user_property              = "email"
  saml_attribute_name        = "https://aws.amazon.com/SAML/Attributes/RoleSessionName"
  saml_attribute_name_format = "Basic"
}

# Note: The aws_role attribute mapper is NOT needed for IAM Identity Center.
# IAM Identity Center uses permission sets and group assignments, not SAML role assertions.

# Creates one Keycloak realm role per IAM Identity Center permission set.
resource "keycloak_role" "aws_roles" {
  for_each = var.keycloak_enabled ? var.keycloak_config.roles : {}

  realm_id    = keycloak_realm.aws[0].id
  name        = each.key
  description = each.value.description
}

# Creates Keycloak groups that mirror the IAM Identity Center groups.
resource "keycloak_group" "aws_groups" {
  for_each = var.keycloak_enabled ? var.keycloak_config.groups : {}

  realm_id = keycloak_realm.aws[0].id
  name     = each.key
}

# Binds each Keycloak group to its roles so members receive the correct AWS role in their SAML assertion.
resource "keycloak_group_roles" "aws_group_roles" {
  for_each = var.keycloak_enabled ? var.keycloak_config.groups : {}

  realm_id = keycloak_realm.aws[0].id
  group_id = keycloak_group.aws_groups[each.key].id
  role_ids = [for r in each.value.roles : keycloak_role.aws_roles[r].id]
}

# Downloads the Keycloak realm SAML descriptor XML that AWS needs to trust Keycloak as an IdP.
data "http" "keycloak_saml_metadata" {
  count = var.keycloak_enabled ? 1 : 0
  url   = "${var.keycloak_config.url}/realms/${var.keycloak_config.realm}/protocol/saml/descriptor"

  depends_on = [keycloak_saml_client.aws_sso]
}

# Registers Keycloak as a trusted SAML Identity Provider in AWS IAM.
resource "aws_iam_saml_provider" "keycloak" {
  count                  = var.keycloak_enabled ? 1 : 0
  name                   = "keycloak-${var.keycloak_config.realm}"
  saml_metadata_document = data.http.keycloak_saml_metadata[0].response_body

  tags = local.common_tags
}

# Stores the Keycloak SAML metadata XML in SSM for the one-time IAM Identity Center
# identity source change: Settings → Change identity source → External IdP → upload XML.
resource "aws_ssm_parameter" "keycloak_saml_metadata" {
  count       = var.keycloak_enabled ? 1 : 0
  name        = "/iam-identity-center/keycloak/${var.keycloak_config.realm}/saml-metadata"
  description = "Keycloak SAML metadata XML for IAM Identity Center external IdP configuration"
  type        = "SecureString"
  value       = data.http.keycloak_saml_metadata[0].response_body

  tags = local.common_tags
}
