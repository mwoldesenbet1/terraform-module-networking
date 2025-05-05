# Create per-AZ route tables for TGW attachment subnets
resource "aws_route_table" "inspection_tgw_rt" {
  provider = aws.delegated_account_us-west-2
  count    = var.tgw_subnet_count
  vpc_id   = aws_vpc.inspection_vpc.id
  
  tags = {
    Name        = "inspection-tgw-rt-${var.az_suffixes[count.index % length(var.az_suffixes)]}"
    Environment = "security"
    ManagedBy   = "terraform"
    Tier        = "tgw"
  }
}

# Route from TGW subnets to Network Firewall endpoints (by AZ)
resource "aws_route" "tgw_to_firewall" {
  provider = aws.delegated_account_us-west-2
  count    = var.tgw_subnet_count
  
  route_table_id         = aws_route_table.inspection_tgw_rt[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = lookup(
    {
      for state in aws_networkfirewall_firewall.inspection_firewall.firewall_status[0].sync_states :
      state.availability_zone => state.attachment[0].endpoint_id
    },
    "${var.aws_region}${var.az_suffixes[count.index % length(var.az_suffixes)]}", 
    null
  )
}

# Associate TGW route tables with TGW subnets (one per AZ)
resource "aws_route_table_association" "tgw_rt_association" {
  provider       = aws.delegated_account_us-west-2
  count          = var.tgw_subnet_count
  subnet_id      = aws_subnet.inspection_tgw_subnets[count.index].id
  route_table_id = aws_route_table.inspection_tgw_rt[count.index].id
}

# Create route table for Network Firewall subnets
resource "aws_route_table" "firewall_rt" {
  provider = aws.delegated_account_us-west-2
  vpc_id   = aws_vpc.inspection_vpc.id
  
  tags = {
    Name        = "inspection-firewall-rt"
    Environment = "security"
    ManagedBy   = "terraform"
    Tier        = "firewall"
  }
}

# Route for return traffic to VPCs via Transit Gateway
resource "aws_route" "firewall_to_vpcs" {
  provider               = aws.delegated_account_us-west-2
  route_table_id         = aws_route_table.firewall_rt.id
  destination_cidr_block = "10.0.0.0/8"  # Adjust to cover your VPC CIDR ranges
  transit_gateway_id     = var.transit_gateway_id
}

# Route for internet-bound traffic to NAT Gateway
resource "aws_route" "firewall_to_nat" {
  provider               = aws.delegated_account_us-west-2
  route_table_id         = aws_route_table.firewall_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.inspection_nat_gw[0].id
}

# Associate firewall route table with firewall subnets
resource "aws_route_table_association" "firewall_rt_association" {
  provider       = aws.delegated_account_us-west-2
  count          = var.private_subnet_count  # Using private subnets for firewall
  subnet_id      = aws_subnet.inspection_private_subnets[count.index].id
  route_table_id = aws_route_table.firewall_rt.id
}

# Update private subnet route tables with routes to other VPCs
resource "aws_route" "private_to_vpcs" {
  provider               = aws.delegated_account_us-west-2
  count                  = var.private_subnet_count
  route_table_id         = aws_route_table.inspection_private_rt[count.index].id
  destination_cidr_block = "10.0.0.0/8"  # Adjust to cover your VPC CIDR ranges
  transit_gateway_id     = var.transit_gateway_id
  depends_on             = [aws_route.private_nat_route]
}

# TGW Route Table to direct traffic through inspection VPC
resource "aws_ec2_transit_gateway_route" "tgw_default_route" {
  provider                       = aws.delegated_account_us-west-2
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection_vpc_attachment.id
  transit_gateway_route_table_id = var.transit_gateway_route_table_id
}