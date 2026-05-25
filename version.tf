terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
    }
    keycloak = {
      source  = "keycloak/keycloak"
      version = ">= 4.5"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}

# When keycloak_enabled = false, initial_login = false prevents the provider
# from trying to connect to Keycloak during init/plan — no resources are created.
provider "keycloak" {
  url           = var.keycloak_enabled && var.keycloak_config != null ? var.keycloak_config.url : "http://localhost"
  client_id     = var.keycloak_enabled && var.keycloak_config != null ? var.keycloak_config.client_id : "admin-cli"
  username      = var.keycloak_enabled && var.keycloak_config != null ? var.keycloak_config.username : ""
  password      = var.keycloak_enabled && var.keycloak_config != null ? var.keycloak_config.password : ""
  initial_login = var.keycloak_enabled
}
