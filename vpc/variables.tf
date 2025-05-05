variable "vpc_names" {
  description = "Names for the VPCs in each region"
  type        = map(string)
  default = {
    "us-west-2"     = "production-vpc"
    "us-west-2-dev" = "development-vpc"
    "us-east-1"     = "nonproduction-vpc"
  }
}

variable "subnet_names" {
  description = "Names for the subnets in each VPC"
  type        = map(list(string))
  default = {
    "us-west-2"     = ["prod-subnet-1", "prod-subnet-2"]
    "us-west-2-dev" = ["dev-subnet-1", "dev-subnet-2"]
    "us-east-1"     = ["nonprod-subnet-1", "nonprod-subnet-2"]
  }
}
variable "ipam_pool_ids" {
  description = "IDs of IPAM pools to use for each VPC"
  type        = map(string)
}

variable "create_nat_gateway" {
  description = "Whether to create NAT Gateways"
  type        = bool
  default     = true
}

variable "create_internet_gateway" {
  description = "Whether to create Internet Gateways"
  type        = bool
  default     = true
}

variable "public_subnet_indices" {
  description = "Indices of the subnets that should be public (have route to IGW)"
  type        = list(number)
  default     = [0]  # By default, first subnet is public
}

variable "private_subnet_indices" {
  description = "Indices of the subnets that should be private (have route to NAT)"
  type        = list(number)
  default     = [1]  # By default, second subnet is private
}
