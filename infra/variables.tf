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

#variable "secret_key_base" {
#  type        = string
#  description = "The secret key base for the application"
#  sensitive   = true
#}

# PoC will deploy without a external DB
#variable "db_username" {
#  type        = string
#  description = "Username for the database"
#  sensitive   = true
#}
#
#variable "db_password" {
#  type        = string
#  description = "Password for the database"
#  sensitive   = true
#}
#
#variable "db_name" {
#  type        = string
#  description = "Name of the database"
#  sensitive   = true
#}

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

