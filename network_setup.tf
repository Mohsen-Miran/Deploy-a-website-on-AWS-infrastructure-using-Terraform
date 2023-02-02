# Provider:
provider "aws" {
  profile = var.profile
  region  = var.region
  alias   = "region"
}

# Create VPC in us-east-1
resource "aws_vpc" "vpc_useast" {
  provider             = aws.region
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"
  tags = {
    Name = "Test-VPC-N.Virginia"
  }
}

# Create IGW in us-east-1
resource "aws_internet_gateway" "igw" {
  provider   = aws.region
  vpc_id     = aws_vpc.vpc_useast.id
  depends_on = [aws_vpc.vpc_useast]
  tags = {
    Name = "Test-VPC-N.Virginia-IGW"
  }
}


# Get all available AZ's in VPC for master region
data "aws_availability_zones" "azs" {
  provider = aws.region
  state    = "available"
}

# Create subnet # 1 in us-east-1
resource "aws_subnet" "subnet_1" {
  provider                = aws.region
  availability_zone       = element(data.aws_availability_zones.azs.names, 0)
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.vpc_useast.id
  cidr_block              = "10.0.1.0/24"
  depends_on              = [aws_vpc.vpc_useast]
  tags = {
    Name = "Test-VPC-N.Virginia-Public1"
  }
}

# Create subnet #2  in us-east-1
resource "aws_subnet" "subnet_2" {
  provider                = aws.region
  vpc_id                  = aws_vpc.vpc_useast.id
  availability_zone       = element(data.aws_availability_zones.azs.names, 1)
  map_public_ip_on_launch = true
  cidr_block              = "10.0.2.0/24"
  depends_on              = [aws_vpc.vpc_useast]
  tags = {
    Name = "Test-VPC-N.Virginia-Public2"
  }
}

# Create subnet #3  in us-east-1
resource "aws_subnet" "subnet_3" {
  provider                = aws.region
  vpc_id                  = aws_vpc.vpc_useast.id
  availability_zone       = element(data.aws_availability_zones.azs.names, 0)
  map_public_ip_on_launch = false
  cidr_block              = "10.0.100.0/24"
  depends_on              = [aws_vpc.vpc_useast]
  tags = {
    Name = "Test-VPC-N.Virginia-Private1"
  }
}

# Create Public Route Table in us-east-1
resource "aws_route_table" "internet_route" {
  provider = aws.region
  vpc_id   = aws_vpc.vpc_useast.id
  tags = {
    Name = "Test-VPC-N.Virginia-PublicRT"
  }
}

# Create Private Route Table in us-east-1
resource "aws_route_table" "private_route_table" {
  provider = aws.region
  vpc_id   = aws_vpc.vpc_useast.id
  tags = {
    Name = "Test-VPC-N.Virginia-PrivateRT"
  }
}

# Add default route in our public routing table to reach out to the Internet
resource "aws_route" "default_route" {
  provider               = aws.region
  route_table_id         = aws_route_table.internet_route.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  depends_on             = [aws_route_table.internet_route, aws_internet_gateway.igw]
}

# Create  route table association for us-east-1 region
resource "aws_route_table_association" "rta-PublicSubnet1" {
  provider       = aws.region
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.internet_route.id
}
resource "aws_route_table_association" "rta-PublicSubnet2" {
  provider       = aws.region
  subnet_id      = aws_subnet.subnet_2.id
  route_table_id = aws_route_table.internet_route.id
}
resource "aws_route_table_association" "rta-PrivateSubnet1" {
  provider       = aws.region
  subnet_id      = aws_subnet.subnet_3.id
  route_table_id = aws_route_table.private_route_table.id
}




