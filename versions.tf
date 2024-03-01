terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.39"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 1.2"
    }
  }
}
