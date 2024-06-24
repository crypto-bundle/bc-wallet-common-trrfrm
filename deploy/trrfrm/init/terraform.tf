terraform {
  required_providers {
    postgresql = {
      source = "cyrilgdn/postgresql"
    }
    vault = {
      source  = "hashicorp/vault"
    }
    random = {
      source  = "hashicorp/random"
    }
  }

  backend "pg" {
  }
}