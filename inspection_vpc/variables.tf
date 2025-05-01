

variable "aws_region" {
  description = "AWS region for the inspection VPC"
  type        = string
  default     = "us-west-2"
}

variable "ipam_pool_id" {
  description = "ID of the IPAM pool to allocate the inspection VPC CIDR from"
  type        = string
}

variable "ipam_netmask_length" {
  description = "Netmask length for the VPC CIDR block to request from IPAM"
  type        = number
  default     = 16
}

variable "public_subnet_count" {
  description = "Number of public subnets to create in the inspection VPC"
  type        = number
  default     = 2
}

variable "private_subnet_count" {
  description = "Number of private subnets to create in the inspection VPC"
  type        = number
  default     = 2
}

variable "tgw_subnet_count" {
  description = "Number of TGW attachment subnets to create in the inspection VPC"
  type        = number
  default     = 2
}

variable "az_suffixes" {
  description = "Availability Zone suffixes for the region"
  type        = list(string)
  default     = ["a", "b"]
}

variable "transit_gateway_id" {
  description = "ID of the Transit Gateway to attach the inspection VPC to"
  type        = string
  default     = ""
}

variable "transit_gateway_route_table_id" {
  description = "ID of the Transit Gateway route table"
  type        = string
}
