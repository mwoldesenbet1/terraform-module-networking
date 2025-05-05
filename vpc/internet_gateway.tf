# Create Internet Gateway for us-west-2 VPC
resource "aws_internet_gateway" "igw_west" {
  provider = aws.delegated_account_us-west-2
  vpc_id   = aws_vpc.vpc_west.id
  
  tags = {
    Name        = "${var.vpc_names["us-west-2"]}-igw"
    Environment = "Production"
  }
}

# Create Internet Gateway for us-east-1 VPC
resource "aws_internet_gateway" "igw_east" {
  provider = aws.delegated_account_us-east-1
  vpc_id   = aws_vpc.vpc_east.id
  
  tags = {
    Name        = "${var.vpc_names["us-east-1"]}-igw"
    Environment = "NonProduction"
  }
}

# Create Internet Gateway for us-west-2 dev VPC
resource "aws_internet_gateway" "igw_dev" {
  provider = aws.delegated_account_us-west-2
  vpc_id   = aws_vpc.vpc_dev.id
  
  tags = {
    Name        = "${var.vpc_names["us-west-2-dev"]}-igw"
    Environment = "Development"
  }
}
