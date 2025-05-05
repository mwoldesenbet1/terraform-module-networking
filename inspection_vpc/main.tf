

# Create the inspection VPC using IPAM allocation
resource "aws_vpc" "inspection_vpc" {
  provider             = aws.delegated_account_us-west-2
  ipv4_ipam_pool_id    = var.ipam_pool_id
  ipv4_netmask_length  = var.ipam_netmask_length
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name        = "inspection_vpc"
    Environment = "security"
    ManagedBy   = "terraform"
  }
}

# Create internet gateway for the inspection VPC
resource "aws_internet_gateway" "inspection_igw" {
  provider = aws.delegated_account_us-west-2
  vpc_id   = aws_vpc.inspection_vpc.id
  
  tags = {
    Name        = "inspection-igw"
    Environment = "security"
    ManagedBy   = "terraform"
  }
}

# Create public subnets 
resource "aws_subnet" "inspection_public_subnets" {
  provider          = aws.delegated_account_us-west-2
  count             = var.public_subnet_count
  vpc_id            = aws_vpc.inspection_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.inspection_vpc.cidr_block, 3, count.index)
  availability_zone = "${var.aws_region}${var.az_suffixes[count.index % length(var.az_suffixes)]}"
  
  tags = {
    Name        = "inspection-public-${var.az_suffixes[count.index % length(var.az_suffixes)]}"
    Environment = "security"
    ManagedBy   = "terraform"
    Tier        = "public"
  }
}

# Create private subnets 
resource "aws_subnet" "inspection_private_subnets" {
  provider          = aws.delegated_account_us-west-2
  count             = var.private_subnet_count
  vpc_id            = aws_vpc.inspection_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.inspection_vpc.cidr_block, 3, count.index + var.public_subnet_count)
  availability_zone = "${var.aws_region}${var.az_suffixes[count.index % length(var.az_suffixes)]}"
  
  tags = {
    Name        = "inspection-private-${var.az_suffixes[count.index % length(var.az_suffixes)]}"
    Environment = "security"
    ManagedBy   = "terraform"
    Tier        = "private"
  }
}
#Create TGW attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "inspection_vpc_attachment" {
  provider           = aws.delegated_account_us-west-2
  subnet_ids         = aws_subnet.inspection_tgw_subnets[*].id
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = aws_vpc.inspection_vpc.id
  
  appliance_mode_support = "enable"
  
  tags = {
    Name = "inspection-vpc-tgw-attachment"
  }
}

# Create TGW attachment subnets
resource "aws_subnet" "inspection_tgw_subnets" {
  provider          = aws.delegated_account_us-west-2
  count             = var.tgw_subnet_count
  vpc_id            = aws_vpc.inspection_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.inspection_vpc.cidr_block, 3, count.index + var.public_subnet_count + var.private_subnet_count)
  availability_zone = "${var.aws_region}${var.az_suffixes[count.index % length(var.az_suffixes)]}"
  
  tags = {
    Name        = "inspection-tgw-${var.az_suffixes[count.index % length(var.az_suffixes)]}"
    Environment = "security"
    ManagedBy   = "terraform"
    Tier        = "tgw"
  }
}

# Create NAT gateways for outbound traffic
resource "aws_eip" "nat_eip" {
  provider = aws.delegated_account_us-west-2
  count    = var.public_subnet_count
  domain   = "vpc"
  
  tags = {
    Name        = "inspection-nat-eip-${var.az_suffixes[count.index % length(var.az_suffixes)]}"
    Environment = "security"
    ManagedBy   = "terraform"
  }
}

resource "aws_nat_gateway" "inspection_nat_gw" {
  provider      = aws.delegated_account_us-west-2
  count         = var.public_subnet_count
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.inspection_public_subnets[count.index].id
  
  tags = {
    Name        = "inspection-nat-gw-${var.az_suffixes[count.index % length(var.az_suffixes)]}"
    Environment = "security"
    ManagedBy   = "terraform"
  }
  
  depends_on = [aws_internet_gateway.inspection_igw]
}

# Create route table for public subnets
resource "aws_route_table" "inspection_public_rt" {
  provider = aws.delegated_account_us-west-2
  vpc_id   = aws_vpc.inspection_vpc.id
  
  tags = {
    Name        = "inspection-public-rt"
    Environment = "security"
    ManagedBy   = "terraform"
    Tier        = "public"
  }
}

# Add default route to internet gateway
resource "aws_route" "public_internet_route" {
  provider               = aws.delegated_account_us-west-2
  route_table_id         = aws_route_table.inspection_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.inspection_igw.id
}

# Associate public route table with public subnets
resource "aws_route_table_association" "public_rt_association" {
  provider       = aws.delegated_account_us-west-2
  count          = var.public_subnet_count
  subnet_id      = aws_subnet.inspection_public_subnets[count.index].id
  route_table_id = aws_route_table.inspection_public_rt.id
}

# Create route tables for private subnets (one per AZ)
resource "aws_route_table" "inspection_private_rt" {
  provider = aws.delegated_account_us-west-2
  count    = var.private_subnet_count
  vpc_id   = aws_vpc.inspection_vpc.id
  
  tags = {
    Name        = "inspection-private-rt-${var.az_suffixes[count.index % length(var.az_suffixes)]}"
    Environment = "security"
    ManagedBy   = "terraform"
    Tier        = "private"
  }
}

# Add NAT gateway routes to private route tables
resource "aws_route" "private_nat_route" {
  provider               = aws.delegated_account_us-west-2
  count                  = var.private_subnet_count
  route_table_id         = aws_route_table.inspection_private_rt[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.inspection_nat_gw[count.index % var.public_subnet_count].id
}

# Associate private route tables with private subnets
resource "aws_route_table_association" "private_rt_association" {
  provider       = aws.delegated_account_us-west-2
  count          = var.private_subnet_count
  subnet_id      = aws_subnet.inspection_private_subnets[count.index].id
  route_table_id = aws_route_table.inspection_private_rt[count.index].id
}


# Create Transit Gateway attachment for the inspection VPC
#resource "aws_ec2_transit_gateway_vpc_attachment" "inspection_vpc_attachment" {
# provider           = aws.delegated_account_us-west-2
# subnet_ids         = aws_subnet.inspection_tgw_subnets[*].id
# transit_gateway_id = var.transit_gateway_id
# vpc_id             = aws_vpc.inspection_vpc.id
  
# appliance_mode_support = "enable"
  
# tags = {
#   Name = "inspection-vpc-tgw-attachment"
# }
#}

# Associate the inspection VPC attachment with the TGW route table
resource "aws_ec2_transit_gateway_route_table_association" "inspection_vpc_rt_association" {
  provider                       = aws.delegated_account_us-west-2
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection_vpc_attachment.id
  transit_gateway_route_table_id = var.transit_gateway_route_table_id
}
