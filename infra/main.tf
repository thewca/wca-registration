terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  # Supports multiple workspaces
  backend "s3" {
    bucket = "wca-registration-terraform-state"
    key    = "wca-registration"
    region = "us-west-2"
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Env = var.env
    }
  }
}
