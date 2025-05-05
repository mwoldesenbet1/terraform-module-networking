# Public Route Tables (with inline routes)
resource "aws_route_table" "public_rt_west" {
  provider = aws.delegated_account_us-west-2
  vpc_id   = aws_vpc.vpc_west.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_west.id
  }

  tags = {
    Name        = "${var.vpc_names["us-west-2"]}-public-rt"
    Environment = "Production"
  }

  lifecycle {
    ignore_changes = [route]
  }
}

resource "aws_route_table" "public_rt_east" {
  provider = aws.delegated_account_us-east-1
  vpc_id   = aws_vpc.vpc_east.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_east.id
  }

  tags = {
    Name        = "${var.vpc_names["us-east-1"]}-public-rt"
    Environment = "NonProduction"
  }

  lifecycle {
    ignore_changes = [route]
  }
}

# Private Route Tables (with inline routes)
resource "aws_route_table" "private_rt_west" {
  provider = aws.delegated_account_us-west-2
  vpc_id   = aws_vpc.vpc_west.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_west.id
  }

  tags = {
    Name        = "${var.vpc_names["us-west-2"]}-private-rt"
    Environment = "Production"
  }

  lifecycle {
    ignore_changes = [route]
  }
}

resource "aws_route_table" "private_rt_east" {
  provider = aws.delegated_account_us-east-1
  vpc_id   = aws_vpc.vpc_east.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_east.id
  }

  tags = {
    Name        = "${var.vpc_names["us-east-1"]}-private-rt"
    Environment = "NonProduction"
  }

  lifecycle {
    ignore_changes = [route]
  }
}

# Public Route Table for dev VPC
resource "aws_route_table" "public_rt_dev" {
  provider = aws.delegated_account_us-west-2
  vpc_id   = aws_vpc.vpc_dev.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_dev.id
  }

  tags = {
    Name        = "${var.vpc_names["us-west-2-dev"]}-public-rt"
    Environment = "Development"
  }

  lifecycle {
    ignore_changes = [route]
  }
}

# Private Route Table for dev VPC
resource "aws_route_table" "private_rt_dev" {
  provider = aws.delegated_account_us-west-2
  vpc_id   = aws_vpc.vpc_dev.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_dev.id
  }

  tags = {
    Name        = "${var.vpc_names["us-west-2-dev"]}-private-rt"
    Environment = "Development"
  }

  lifecycle {
    ignore_changes = [route]
  }
}

# Route Table Associations for dev VPC
resource "aws_route_table_association" "public_rta_dev" {
  provider       = aws.delegated_account_us-west-2
  subnet_id      = aws_subnet.subnet_dev[0].id
  route_table_id = aws_route_table.public_rt_dev.id
}

resource "aws_route_table_association" "private_rta_dev" {
  provider       = aws.delegated_account_us-west-2
  subnet_id      = aws_subnet.subnet_dev[1].id
  route_table_id = aws_route_table.private_rt_dev.id
}

# Route Table Associations 
resource "aws_route_table_association" "public_rta_west" {
  provider       = aws.delegated_account_us-west-2
  subnet_id      = aws_subnet.subnet_west[0].id
  route_table_id = aws_route_table.public_rt_west.id
}

resource "aws_route_table_association" "private_rta_west" {
  provider       = aws.delegated_account_us-west-2
  subnet_id      = aws_subnet.subnet_west[1].id
  route_table_id = aws_route_table.private_rt_west.id
}

resource "aws_route_table_association" "public_rta_east" {
  provider       = aws.delegated_account_us-east-1
  subnet_id      = aws_subnet.subnet_east[0].id
  route_table_id = aws_route_table.public_rt_east.id
}

resource "aws_route_table_association" "private_rta_east" {
  provider       = aws.delegated_account_us-east-1
  subnet_id      = aws_subnet.subnet_east[1].id
  route_table_id = aws_route_table.private_rt_east.id
}