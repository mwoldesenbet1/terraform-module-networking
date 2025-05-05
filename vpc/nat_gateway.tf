# Create Elastic IPs for NAT Gateways
resource "aws_eip" "nat_eip_west" {
  provider = aws.delegated_account_us-west-2
  domain   = "vpc"
  
  tags = {
    Name        = "${var.vpc_names["us-west-2"]}-nat-eip"
    Environment = "Production"
  }
}

resource "aws_eip" "nat_eip_east" {
  provider = aws.delegated_account_us-east-1
  domain   = "vpc"
  
  tags = {
    Name        = "${var.vpc_names["us-east-1"]}-nat-eip"
    Environment = "NonProduction"
  }
}

# Create NAT Gateway in us-west-2 (in the first subnet)
resource "aws_nat_gateway" "nat_gw_west" {
  provider      = aws.delegated_account_us-west-2
  allocation_id = aws_eip.nat_eip_west.id
  subnet_id     = aws_subnet.subnet_west[0].id
  
  tags = {
    Name        = "${var.vpc_names["us-west-2"]}-nat-gw"
    Environment = "Production"
  }
  
  # Ensure the Internet Gateway is created first
  depends_on = [aws_internet_gateway.igw_west]
}

# Create NAT Gateway in us-east-1 (in the first subnet)
resource "aws_nat_gateway" "nat_gw_east" {
  provider      = aws.delegated_account_us-east-1
  allocation_id = aws_eip.nat_eip_east.id
  subnet_id     = aws_subnet.subnet_east[0].id
  
  tags = {
    Name        = "${var.vpc_names["us-east-1"]}-nat-gw"
    Environment = "NonProduction"
  }
  
  # Ensure the Internet Gateway is created first
  depends_on = [aws_internet_gateway.igw_east]
}

# Create Elastic IP for NAT Gateway in dev VPC
resource "aws_eip" "nat_eip_dev" {
  provider = aws.delegated_account_us-west-2
  domain   = "vpc"
  
  tags = {
    Name        = "${var.vpc_names["us-west-2-dev"]}-nat-eip"
    Environment = "Development"
  }
}

# Create NAT Gateway in us-west-2 dev VPC
resource "aws_nat_gateway" "nat_gw_dev" {
  provider      = aws.delegated_account_us-west-2
  allocation_id = aws_eip.nat_eip_dev.id
  subnet_id     = aws_subnet.subnet_dev[0].id
  
  tags = {
    Name        = "${var.vpc_names["us-west-2-dev"]}-nat-gw"
    Environment = "Development"
  }
  
  # Ensure the Internet Gateway is created first
  depends_on = [aws_internet_gateway.igw_dev]
}
