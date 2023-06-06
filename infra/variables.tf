variable "env" {
  type        = string
  description = "Environment name"
  default     = "prod"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for naming resources"
  default     = "wca-registration"
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

variable "host" {
  type        = string
  description = "The host for generating absolute URLs in the application"
  default     = "register.worldcubeassociation.org"
}

variable "wca_host" {
  type        = string
  description = "The host for generating absolute URLs in the application"
  default     = "worldcubeassociation.org"
}

