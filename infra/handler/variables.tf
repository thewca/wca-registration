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

variable "prometheus_address" {
  type = string
  description = "The Address that prometheus is running at"
  default = "prometheus.worldcubeassociation.org"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for naming resources"
  default     = "wca-registration-handler"
}

variable "api_gateway_url" {
  type = string
  description = "The URL to invoke the API Gateway"
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

variable "shared_resources" {
  description = "All the resources that the two Modules both use"
  type = object({
    dynamo_registration_table: string,
    queue: object({
      arn: string,
      url: string
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
    main_target_group: object({
      arn: string
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
