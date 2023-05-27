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

module "shared_resources" {
  source = "./shared"
}

module "handler" {
  source = "./handler"

  shared_resources = module.shared_resources
  depends_on = [module.shared_resources]
}

module "worker" {
  source = "./worker"

  shared_resources = module.shared_resources
  depends_on = [module.shared_resources]
}

module "frontend" {
  source = "./frontend"
}

module "staging" {
  source = "./staging"
}