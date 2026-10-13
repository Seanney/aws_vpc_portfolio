HIGH AVAILABILITY NAT GATEWAY
provider "aws" {
  region = "eu-north-1"
}

resource "aws_vpc" "soanova_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "soanova_vpc"
  }
}


resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.soanova_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-north-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet1"
  }
}


resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.soanova_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-north-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet2"
  }
}

resource "aws_internet_gateway" "main_internet_gateway" {
  vpc_id = aws_vpc.soanova_vpc.id
  tags = {
    Name = "internet_gateway"
  }
}

resource "aws_route_table" "main_route_table" {
  vpc_id = aws_vpc.soanova_vpc.id
  route {
    gateway_id = aws_internet_gateway.main_internet_gateway.id
    cidr_block = "0.0.0.0/0"
  }
  tags = {
    Name = "route_table"
  }
}

resource "aws_route_table_association" "public_subnet1" {
  route_table_id = aws_route_table.main_route_table.id
  subnet_id      = aws_subnet.public_subnet1.id
}

resource "aws_route_table_association" "public_subnet2" {
  route_table_id = aws_route_table.main_route_table.id
  subnet_id      = aws_subnet.public_subnet2.id
}
resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.soanova_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-north-1a"
  tags = {
    Name = "private_subnet1"
  }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id            = aws_vpc.soanova_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-north-1b"
  tags = {
    Name = "private_subnet2"
  }
}

resource "aws_eip" "nat1" {
  domain = "vpc"
  tags = {
    Name = "nat_eip1"
  }
}

resource "aws_nat_gateway" "nat_gateway1" {
  allocation_id = aws_eip.nat1.id
  subnet_id     = aws_subnet.public_subnet1.id
  tags = {
    Name = "nat_gateway1"
  }
 depends_on = [
    aws_internet_gateway.main_internet_gateway
  ]
}

resource "aws_eip" "nat2" {
  domain = "vpc"
  tags = {
    Name = "nat_eip2"
  }
}

resource "aws_nat_gateway" "nat_gateway2" {
  allocation_id = aws_eip.nat2.id
  subnet_id     = aws_subnet.public_subnet2.id
  tags = {
    Name = "nat_gateway2"
  }
  depends_on = [
    aws_internet_gateway.main_internet_gateway
  ]
}
resource "aws_route_table" "private1" {
  vpc_id = aws_vpc.soanova_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway1.id
 }
  tags = {
    Name = "private_subnet1_route_table"
  }
}

resource "aws_route_table" "private2" {
  vpc_id = aws_vpc.soanova_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway2.id
  }
  tags = {
    Name = "private_subnet2_route_table"
  }
}


resource "aws_route_table_association" "private_subnet1" {
  route_table_id = aws_route_table.private1.id
  subnet_id      = aws_subnet.private_subnet1.id
}

resource "aws_route_table_association" "private_subnet2" {
  route_table_id = aws_route_table.private2.id
  subnet_id      = aws_subnet.private_subnet2.id
}

