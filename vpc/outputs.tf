output "vpc_ids" {
  description = "IDs of the created VPCs"
  value = {
    "${var.aws_regions[0]}"     = aws_vpc.vpc_west.id
    "${var.aws_regions[0]}-dev" = aws_vpc.vpc_dev.id
    "${var.aws_regions[1]}"     = aws_vpc.vpc_east.id
  }
}

output "vpc_cidrs" {
  description = "CIDR blocks of the created VPCs"
  value = {
    "${var.aws_regions[0]}"     = aws_vpc.vpc_west.cidr_block
    "${var.aws_regions[0]}-dev" = aws_vpc.vpc_dev.cidr_block
    "${var.aws_regions[1]}"     = aws_vpc.vpc_east.cidr_block
  }
}

output "subnet_ids" {
  description = "IDs of the created subnets"
  value = {
    "${var.aws_regions[0]}"     = aws_subnet.subnet_west[*].id
    "${var.aws_regions[0]}-dev" = aws_subnet.subnet_dev[*].id
    "${var.aws_regions[1]}"     = aws_subnet.subnet_east[*].id
  }
}

output "subnet_cidrs" {
  description = "CIDR blocks of the created subnets"
  value = {
    "${var.aws_regions[0]}"     = aws_subnet.subnet_west[*].cidr_block
    "${var.aws_regions[0]}-dev" = aws_subnet.subnet_dev[*].cidr_block
    "${var.aws_regions[1]}"     = aws_subnet.subnet_east[*].cidr_block
  }
}

output "internet_gateway_ids" {
  description = "IDs of the created Internet Gateways"
  value = {
    "${var.aws_regions[0]}"     = aws_internet_gateway.igw_west.id
    "${var.aws_regions[0]}-dev" = aws_internet_gateway.igw_dev.id
    "${var.aws_regions[1]}"     = aws_internet_gateway.igw_east.id
  }
}

output "nat_gateway_ids" {
  description = "IDs of the created NAT Gateways"
  value = {
    "${var.aws_regions[0]}"     = aws_nat_gateway.nat_gw_west.id
    "${var.aws_regions[0]}-dev" = aws_nat_gateway.nat_gw_dev.id
    "${var.aws_regions[1]}"     = aws_nat_gateway.nat_gw_east.id
  }
}

output "route_table_ids" {
  description = "IDs of the created Route Tables"
  value = {
    "${var.aws_regions[0]}-public"      = aws_route_table.public_rt_west.id
    "${var.aws_regions[0]}-private"     = aws_route_table.private_rt_west.id
    "${var.aws_regions[0]}-dev-public"  = aws_route_table.public_rt_dev.id
    "${var.aws_regions[0]}-dev-private" = aws_route_table.private_rt_dev.id
    "${var.aws_regions[1]}-public"      = aws_route_table.public_rt_east.id
    "${var.aws_regions[1]}-private"     = aws_route_table.private_rt_east.id
  }
}