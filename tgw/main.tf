# Transit Gateway - central hub for VPC connectivity
resource "aws_ec2_transit_gateway" "tgw" {
  provider = aws.delegated_account_us-west-2
  
  description                     = "Transit Gateway us-west-2"
  amazon_side_asn                 = var.amazon_side_asn
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"
  
  tags = {
    Name        = var.tgw_name
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}

# Default Transit Gateway Route Table
resource "aws_ec2_transit_gateway_route_table" "tgw_rt" {
  provider = aws.delegated_account_us-west-2
  
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  
  tags = {
    Name        = "${var.tgw_name}-rt"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}


# Transit Gateway in us-east-1
resource "aws_ec2_transit_gateway" "tgw_east" {
  provider = aws.delegated_account_us-east-1

  description                     = "Transit Gateway us-east-1"
  amazon_side_asn                 = var.amazon_side_asn + 1  # Use a different ASN
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = {
    Name        = "${var.tgw_name}-east"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}

# Default Transit Gateway Route Table for us-east-1
resource "aws_ec2_transit_gateway_route_table" "tgw_rt_east" {
  provider = aws.delegated_account_us-east-1

  transit_gateway_id = aws_ec2_transit_gateway.tgw_east.id

  tags = {
    Name        = "${var.tgw_name}-east-rt"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}

# Create a dedicated route table for spoke VPCs
resource "aws_ec2_transit_gateway_route_table" "spoke_rt" {
  provider = aws.delegated_account_us-west-2
  
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  
  tags = {
    Name        = "${var.tgw_name}-spoke-rt"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}

# Create a dedicated route table for the inspection VPC
resource "aws_ec2_transit_gateway_route_table" "inspection_rt" {
  provider = aws.delegated_account_us-west-2
  
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  
  tags = {
    Name        = "${var.tgw_name}-inspection-rt"
    Environment = "shared"
    ManagedBy   = "terraform"
  }
}
