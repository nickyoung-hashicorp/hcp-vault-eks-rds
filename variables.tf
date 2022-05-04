variable "hvn_id" {
  description = "The ID of the HCP HVN."
  type        = string
  default     = "learn-hcp-vault-hvn"
}

variable "cluster_id" {
  description = "The ID of the HCP Vault cluster."
  type        = string
  default     = "learn-hcp-vault-cluster"
}

variable "peering_id" {
  description = "The ID of the HCP peering connection."
  type        = string
  default     = "learn-peering"
}

variable "route_id" {
  description = "The ID of the HCP HVN route."
  type        = string
  default     = "learn-hvn-route"
}

variable "hcp_region" {
  description = "The region of the HCP HVN and Vault cluster."
  type        = string
  default     = "us-west-2"
}

variable "cloud_provider" {
  description = "The cloud provider of the HCP HVN and Vault cluster."
  type        = string
  default     = "aws"
}

variable "tier" {
  description = "Tier of the HCP Vault cluster. Valid options for tiers."
  type        = string
  default     = "dev"
}

variable "aws_region" {
  default = "us-west-2"
  description = "The target AWS region."
  type = string
}

variable "rds-vpc-cidr" {
  default     = "10.0.0.0/24"
  description = "The IPv4 CIDR block for the VPC containing the RDS database."
  type        = string
}

variable "rds-subnet-az-a" {
  default     = "us-west-2a"
  description = "First availability zone for the first RDS database subnet."
  type        = string
}

variable "rds-subnet-az-b" {
  default     = "us-west-2b"
  description = "Second availability zone for the second RDS database subnet."
  type        = string
}

variable "rds-subnet-cidr-a" {
  default     = "10.0.0.0/25"
  description = "IPv4 CIDR block for the first availability zone and RDS database subnet."
  type        = string
}

variable "rds-subnet-cidr-b" {
  default     = "10.0.0.128/25"
  description = "IPv4 CIDR block for the second availability zone and RDS database subnet."
  type        = string
}