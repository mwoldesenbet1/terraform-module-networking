# Create route table for TGW attachment subnets
resource "aws_route_table" "inspection_tgw_rt" {
  provider = aws.delegated_account_us-west-2
  vpc_id   = aws_vpc.inspection_vpc.id
  
  tags = {
    Name        = "inspection-tgw-rt"
    Environment = "security"
    ManagedBy   = "terraform"
    Tier        = "tgw"
  }
}

# Add a default route to the private subnets (for traffic coming from TGW)
resource "aws_route" "tgw_to_nat" {
  provider               = aws.delegated_account_us-west-2
  route_table_id         = aws_route_table.inspection_tgw_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.inspection_nat_gw[0].id
}

# Associate TGW route table with TGW subnets
resource "aws_route_table_association" "tgw_rt_association" {
  provider       = aws.delegated_account_us-west-2
  count          = var.tgw_subnet_count
  subnet_id      = aws_subnet.inspection_tgw_subnets[count.index].id
  route_table_id = aws_route_table.inspection_tgw_rt.id
}

# TGW Route Table modifications to direct traffic through inspection VPC
resource "aws_ec2_transit_gateway_route" "tgw_default_route" {
  provider                       = aws.delegated_account_us-west-2
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection_vpc_attachment.id
  transit_gateway_route_table_id = var.transit_gateway_route_table_id
}
