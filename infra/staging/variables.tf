variable "env" {
  type        = string
  description = "Environment name"
  default     = "staging"
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

variable "prometheus_address" {
  type = string
  description = "The Address that prometheus is running at"
  default = "prometheus.worldcubeassociation.org"
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
  description = "The host for generating absolute URLs in the application"
  default     = "staging.worldcubeassociation.org"
}

variable "registration-handler-ecr-repository" {
  type = string
  description = "The Repository for the Handler"
}

variable "registration-worker-ecr-repository" {
  type = string
  description = "The Repository for the Worker"
}
