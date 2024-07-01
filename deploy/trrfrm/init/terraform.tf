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
    time = {
      source = "hashicorp/time"
      version = "0.11.2"
    }
    jwt = {
      source = "camptocamp/jwt"
      version = "1.1.2"
    }
  }

  backend "pg" {
  }
}