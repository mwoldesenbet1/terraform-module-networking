variable "aws_regions" {
  type        = list(string)
  description = "List of AWS regions for Transit Gateway operation"
  default     = ["us-west-2", "us-east-1"]
}

variable "delegated_account_id" {
  description = "AWS Account ID for delegated account where Transit Gateway is created"
  type        = string
}

variable "tgw_name" {
  description = "Name of the Transit Gateway"
  type        = string
  default     = "delegated-account-tgw"
}

variable "amazon_side_asn" {
  description = "Private Autonomous System Number (ASN) for the Amazon side of a BGP session"
  type        = number
  default     = 64512
}

# VPC resources from VPC module
variable "vpc_west_id" {
  description = "ID of the VPC in us-west-2"
  type        = string
}

variable "vpc_east_id" {
  description = "ID of the VPC in us-east-1"
  type        = string
}

variable "vpc_west_subnet_ids" {
  description = "IDs of subnets in us-west-2 VPC for TGW attachment"
  type        = list(string)
}

variable "vpc_east_subnet_ids" {
  description = "IDs of subnets in us-east-1 VPC for TGW attachment"
  type        = list(string)
}

variable "vpc_west_cidr" {
  description = "CIDR block of the VPC in us-west-2"
  type        = string
}

variable "vpc_east_cidr" {
  description = "CIDR block of the VPC in us-east-1"
  type        = string
}

variable "vpc_names" {
  description = "Names for the VPCs in each region"
  type        = map(string)
  default = {
    "us-west-2" = "production-vpc"
    "us-east-1" = "nonproduction-vpc"
  }
}

variable "vpc_west_route_table_ids" {
  description = "IDs of the route tables in us-west-2 VPC"
  type        = map(string)
}

variable "vpc_east_route_table_ids" {
  description = "IDs of the route tables in us-east-1 VPC"
  type        = map(string)
}

variable "rsm_vpn" {
  description = "IP address allowed for SSH access (CIDR notation)"
  type        = string
  default     = "0.0.0.0/0" 
}

variable "vpc_dev_id" {
  description = "ID of the development VPC in us-west-2"
  type        = string
}

variable "vpc_dev_subnet_ids" {
  description = "IDs of subnets in us-west-2 development VPC for TGW attachment"
  type        = list(string)
}

variable "vpc_dev_cidr" {
  description = "CIDR block of the development VPC in us-west-2"
  type        = string
}

variable "vpc_dev_route_table_ids" {
  description = "IDs of the route tables in us-west-2 development VPC"
  type        = map(string)
}

variable "inspection_vpc_attachment_id" {
  description = "ID of the inspection VPC attachment to Transit Gateway"
  type        = string
}
