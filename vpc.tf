resource "aws_vpc" "custom-vpc-application" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "application"
  }
}

resource "aws_subnet" "application-subnet-a" {
  vpc_id     = aws_vpc.custom-vpc-application.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "application"
  }
}

resource "aws_subnet" "application-subnet-b" {
  vpc_id     = aws_vpc.custom-vpc-application.id
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "application"
  }
}

resource "aws_internet_gateway" "application-internet-gateway" {
  vpc_id = aws_vpc.custom-vpc-application.id
  tags = {
    Name = "application"
  }
}

resource "aws_route_table" "internet-gw-route-table" {
  vpc_id = aws_vpc.custom-vpc-application.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.application-internet-gateway.id
  }
  tags = {
    Name = "application"
  }
}

resource "aws_route_table_association" "subnet-a-association" {
  subnet_id      = aws_subnet.application-subnet-a.id
  route_table_id = aws_route_table.internet-gw-route-table.id
}

resource "aws_route_table_association" "subnet-b-association" {
  subnet_id      = aws_subnet.application-subnet-b.id
  route_table_id = aws_route_table.internet-gw-route-table.id
}

