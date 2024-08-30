terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.58"
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

module "worker" {
  source = "./worker"

  shared_resources = module.shared_resources
  depends_on = [module.shared_resources]
}

module "handler" {
  source = "./handler"

  shared_resources = module.shared_resources
  depends_on = [module.shared_resources]
}

module "staging" {
  source = "./staging"
  api_gateway = module.shared_resources.api_gateway
  registration-handler-ecr-repository = module.handler.ecr_repository_url
  registration-worker-ecr-repository = module.worker.ecr_repository_url
  private_subnets = module.shared_resources.private_subnets
  vpc_id = module.shared_resources.vpc_id
  cluster_security_id = module.shared_resources.cluster_security.id
  elasticache_subnet_group_name = module.shared_resources.elasticache_subnet_group.name
  depends_on = [module.shared_resources]
}
