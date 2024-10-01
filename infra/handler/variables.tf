variable "env" {
  type        = string
  description = "Environment name"
  default     = "prod"
}

variable "vault_address" {
  type = string
  description = "The Address that vault is running at"
  default = "http://vault.worldcubeassociation.org:8200"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for naming resources"
  default     = "wca-registration-handler"
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
  default     = "registration.worldcubeassociation.org"
}

variable "wca_host" {
  type        = string
  description = "The host for generating URLs to the monolith"
  default     = "https://www.worldcubeassociation.org"
}

variable "shared_resources" {
  description = "All the resources that the two Modules both use"
  type = object({
    dynamo_registration_table: object({
      name: string,
      arn: string
    }),
    dynamo_registration_history_table: object({
      name: string,
      arn: string
    }),
    dynamo_waiting_list_table: object({
      name: string,
      arn: string
    }),
    queue: object({
      arn: string,
      name: string
    }),
    ecs_cluster: object({
      id: string,
      name: string
    }),
    lb: object({
      arn_suffix: string
    })
    capacity_provider: object({
      name: string
    }),
    cluster_security: object({
      id: string
    }),
    private_subnets: any,
    https_listener: object({
      arn: string
    }),
    main_target_group: object({
      name: string,
      arn: string,
      arn_suffix: string
    }),
    secondary_target_group: object({
      name: string,
      arn: string
    }),
    aws_elasticache_cluster: object({
      cache_nodes: any
    })
  })
}
