# Routes from us-west-2 to us-east-1
resource "aws_route" "west_public_to_east" {
  provider = aws.delegated_account_us-west-2
  
  route_table_id         = var.vpc_west_route_table_ids["public"]
  destination_cidr_block = var.vpc_east_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

resource "aws_route" "west_private_to_east" {
  provider = aws.delegated_account_us-west-2
  
  route_table_id         = var.vpc_west_route_table_ids["private"]
  destination_cidr_block = var.vpc_east_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

# Routes from us-east-1 to us-west-2
resource "aws_route" "east_public_to_west" {
  provider = aws.delegated_account_us-east-1

  route_table_id         = var.vpc_east_route_table_ids["public"]
  destination_cidr_block = var.vpc_west_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.tgw_east.id
}

resource "aws_route" "east_private_to_west" {
  provider = aws.delegated_account_us-east-1

  route_table_id         = var.vpc_east_route_table_ids["private"]
  destination_cidr_block = var.vpc_west_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.tgw_east.id
}

# Associate spoke VPCs with the spoke route table
resource "aws_ec2_transit_gateway_route_table_association" "prod_vpc_association" {
  provider = aws.delegated_account_us-west-2
  
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc_west_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_rt.id
}

resource "aws_ec2_transit_gateway_route_table_association" "dev_vpc_association" {
  provider = aws.delegated_account_us-west-2
  
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc_dev_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_rt.id
}

# Associate inspection VPC with the inspection route table
resource "aws_ec2_transit_gateway_route_table_association" "inspection_vpc_association" {
  provider = aws.delegated_account_us-west-2
  
  transit_gateway_attachment_id  = var.inspection_vpc_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection_rt.id
}

# Default route from spoke VPCs to the inspection VPC
resource "aws_ec2_transit_gateway_route" "default_to_inspection" {
  provider = aws.delegated_account_us-west-2
  
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke_rt.id
  destination_cidr_block        = "0.0.0.0/0"
  transit_gateway_attachment_id = var.inspection_vpc_attachment_id
}

# Propagate production VPC routes to the inspection route table
resource "aws_ec2_transit_gateway_route_table_propagation" "prod_to_inspection" {
  provider = aws.delegated_account_us-west-2
  
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc_west_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection_rt.id
}

# Propagate development VPC routes to the inspection route table
resource "aws_ec2_transit_gateway_route_table_propagation" "dev_to_inspection" {
  provider = aws.delegated_account_us-west-2
  
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.vpc_dev_attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection_rt.id
}
