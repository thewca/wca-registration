variable "env" {
  type        = string
  description = "Environment name"
  default     = "staging"
}

variable "host" {
  type = string
  description = "The address of the service"
  default = "staging.registration.worldcubeassociation.org"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for naming resources"
  default     = "wca-registration-staging"
}

variable "vault_address" {
  type = string
  description = "The Address that vault is running at"
  default = "http://vault.worldcubeassociation.org:8200"
}

variable "region" {
  type        = string
  description = "The region to operate in"
  default     = "us-west-2"
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability zones"
  default     = ["us-west-2a", "us-west-2b"]
}

variable "wca_host" {
  type        = string
  description = "The host for the WCA Monolith"
  default     = "https://staging.worldcubeassociation.org"
}

variable "registration-handler-ecr-repository" {
  type = string
  description = "The Repository for the Handler"
}

variable "registration-worker-ecr-repository" {
  type = string
  description = "The Repository for the Worker"
}

variable "vpc_id" {
  type = string
  description = "The VPC of the service"
}

variable "private_subnets" {
  type = any
  description = "A list of private subnets of the service"
}

variable "cluster_security_id" {
  type = string
  description = "The security group of the cluster"
}

variable "elasticache_subnet_group_name" {
  type = string
  description = "The subnet group for the cache clusters"
}

variable "api_gateway" {
  type = object({
    id: string,
    root_resource_id: string
  })
}
