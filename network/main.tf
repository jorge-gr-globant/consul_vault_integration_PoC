# Resources
# https://hands-on.cloud/terraform-recipe-managing-aws-vpc-creating-private-subnets/

provider "aws" {
  region = var.aws_region
}

terraform {
  required_version = ">= 0.12, < 0.13"
}

############################
# AWS VPC
############################
resource "aws_vpc" "consul" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
    Project     = var.project_name
  }
}

############################
# Internet Gateway
############################
resource "aws_internet_gateway" "consul-igw" {
  vpc_id = aws_vpc.consul.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-igw"
    Environment = var.environment
    Project     = var.project_name
  }
}


############################
# NAT Gateway
############################
#resource "aws_eip" "consul_nat_ip" {
#  vpc = true
#}

resource "aws_nat_gateway" "consul-nat" {
  allocation_id = data.aws_eip.consul_nat_ip.id
  subnet_id     = aws_subnet.public-subnet-1.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-nat"
    Environment = var.environment
    Project     = var.project_name
  }
}

############################
# Create Public Subnets
############################
resource "aws_subnet" "public-subnet-1" {
  vpc_id            = aws_vpc.consul.id
  cidr_block        = var.public_subnet_cidr_1
  availability_zone = var.aws_availability_zone_1

  tags = {
    Name        = "${var.project_name}-${var.environment}-public_1_subnet"
    Environment = var.environment
    Project     = var.project_name
    Tier        = var.tier_public
  }
}

resource "aws_subnet" "public-subnet-2" {
  vpc_id            = aws_vpc.consul.id
  cidr_block        = var.public_subnet_cidr_2
  availability_zone = var.aws_availability_zone_2

  tags = {
    Name        = "${var.project_name}-${var.environment}-public_2_subnet"
    Environment = var.environment
    Project     = var.project_name
    Tier        = var.tier_public
  }
}

resource "aws_subnet" "public-subnet-3" {
  vpc_id            = aws_vpc.consul.id
  cidr_block        = var.public_subnet_cidr_3
  availability_zone = var.aws_availability_zone_3

  tags = {
    Name        = "${var.project_name}-${var.environment}-public_3_subnet"
    Environment = var.environment
    Project     = var.project_name
    Tier        = var.tier_public
  }
}


############################
# Create Private Subnets
############################
resource "aws_subnet" "private-subnet-1" {
  vpc_id            = aws_vpc.consul.id
  cidr_block        = var.private_subnet_cidr_1
  availability_zone = var.aws_availability_zone_1

  tags = {
    Name        = "${var.project_name}-${var.environment}-private_1_subnet"
    Environment = var.environment
    Project     = var.project_name
    Tier        = var.tier_private
  }
}

resource "aws_subnet" "private-subnet-2" {
  vpc_id            = aws_vpc.consul.id
  cidr_block        = var.private_subnet_cidr_2
  availability_zone = var.aws_availability_zone_2

  tags = {
    Name        = "${var.project_name}-${var.environment}-private_2_subnet"
    Environment = var.environment
    Project     = var.project_name
    Tier        = var.tier_private
  }
}

resource "aws_subnet" "private-subnet-3" {
  vpc_id            = aws_vpc.consul.id
  cidr_block        = var.private_subnet_cidr_3
  availability_zone = var.aws_availability_zone_3

  tags = {
    Name        = "${var.project_name}-${var.environment}-private_3_subnet"
    Environment = var.environment
    Project     = var.project_name
    Tier        = var.tier_private
  }
}

############################
# Public Table Route
############################
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.consul.id

  route {
    cidr_block = var.all_cidrs
    gateway_id = aws_internet_gateway.consul-igw.id
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-route_public"
    Environment = var.environment
    Project     = var.project_name
    Tier        = var.tier_public
  }
}

############################
# Private Table Route
############################
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.consul.id

  route {
    cidr_block = var.all_cidrs
    gateway_id = aws_nat_gateway.consul-nat.id
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-route_private"
    Environment = var.environment
    Project     = var.project_name
    Tier        = var.tier_private
  }
}


############################
# Public Routing
############################
resource "aws_route_table_association" "public-rt-1" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "public-rt-2" {
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "public-rt-3" {
  subnet_id      = aws_subnet.public-subnet-3.id
  route_table_id = aws_route_table.public-rt.id
}

############################
# Private Routing
############################
resource "aws_route_table_association" "private_rt-1" {
  subnet_id      = aws_subnet.private-subnet-1.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "private_rt-2" {
  subnet_id      = aws_subnet.private-subnet-2.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "private_rt-3" {
  subnet_id      = aws_subnet.private-subnet-3.id
  route_table_id = aws_route_table.private-rt.id
}
