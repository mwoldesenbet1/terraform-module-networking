# Peering connection from us-west-2 to us-east-1
resource "aws_ec2_transit_gateway_peering_attachment" "tgw_peering" {
  provider = aws.delegated_account_us-west-2
  
  transit_gateway_id      = aws_ec2_transit_gateway.tgw.id
  peer_account_id         = var.delegated_account_id
  peer_region             = var.aws_regions[1]
  peer_transit_gateway_id = aws_ec2_transit_gateway.tgw_east.id
  
  tags = {
    Name        = "tgw-peering-west-to-east"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}

# Accept the peering request
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "tgw_peering_accepter" {
  provider = aws.delegated_account_us-east-1
  
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.tgw_peering.id
  
  tags = {
    Name        = "tgw-peering-east-to-west-accepter"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}


# Route from west to east via peering
resource "aws_ec2_transit_gateway_route" "west_to_east" {
  provider = aws.delegated_account_us-west-2

  destination_cidr_block         = var.vpc_east_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peering.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_rt.id

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter]
}

# Route from east to west via peering
resource "aws_ec2_transit_gateway_route" "east_to_west" {
  provider = aws.delegated_account_us-east-1

  destination_cidr_block         = var.vpc_west_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peering.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.tgw_rt_east.id

  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_accepter]
}



