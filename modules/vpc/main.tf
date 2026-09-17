// VPC
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "minishop-vpc-lab"
  }
}

# Public Subnet 1
resource "aws_subnet" "public-subnet-A" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_A
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-A"
  }
}


# Public Subnet 2
resource "aws_subnet" "public-subnet-B" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_B
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-B"
  }
}



# Private Subnet 1
resource "aws_subnet" "private-subnet-A" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_A
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet-A"
  }
}

# Private Subnet 2
resource "aws_subnet" "private-subnet-B" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_B
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet-B"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "minishop-internet-gateway"
  }
}


# Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "minishop-demo-public-route-table"
  }
}


# Private Route Table 
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "minishop-demo-private-route-table"
  }
}

# Route Association With the Public Route Table 
resource "aws_route_table_association" "public-subnet-association-1" {
  subnet_id      = aws_subnet.public-subnet-A.id
  route_table_id = aws_route_table.public_route_table.id
}

# Route Association With the Public Route Table
resource "aws_route_table_association" "public-subnet-association-2" {
  subnet_id      = aws_subnet.public-subnet-B.id
  route_table_id = aws_route_table.public_route_table.id
}


# Route Association With the Private Route Table
resource "aws_route_table_association" "private-subnet-association-1" {
  subnet_id      = aws_subnet.private-subnet-A.id
  route_table_id = aws_route_table.private_route_table.id
}


# Route Association With the Private Route Table
resource "aws_route_table_association" "private-subnet-association-2" {
  subnet_id      = aws_subnet.private-subnet-B.id
  route_table_id = aws_route_table.private_route_table.id
}



# Elastic Ip
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "minishop-nat-eip"
  }
}

# Nat Gateway
resource "aws_nat_gateway" "private_nat_gateway" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-subnet-A.id
  depends_on = [ aws_internet_gateway.igw ]
  tags = {
    Name = "minishop-nat-gateway"
  }
}

# Connect Nat Gateway With the Private Route Table
resource "aws_route" "private_aws_route_nat_gateway" {
  route_table_id         = aws_route_table.private_route_table.id
  nat_gateway_id         = aws_nat_gateway.private_nat_gateway.id
  destination_cidr_block = "0.0.0.0/0"
}

# Connect Internet Gateway With the Public Route Table
resource "aws_route" "public_aws_route_internet_gateway" {
  route_table_id         = aws_route_table.public_route_table.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}