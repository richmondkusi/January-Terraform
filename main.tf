# configuring our network for Tenacity IT
resource "aws_vpc" "Prod-VPC" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "Prod-VPC"
    Environment = "Test"
  }
}

# creating public subnet1
resource "aws_subnet" "Prod-pub-sub1" {
  vpc_id     = aws_vpc.Prod-VPC.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-2a" 
  tags = {
    Name = "Prod-pub-sub1"
    Environment = "Test"
  }
}
# creating public subnet2 
resource "aws_subnet" "Prod-pub-sub2" {
  vpc_id     = aws_vpc.Prod-VPC.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-west-2a"
  tags = {
    Name = "Prod-pub-sub2"
    Environment = "Test"
  }
}

# creating private subnet1
resource "aws_subnet" "Prod-priv-sub1" {
  vpc_id     = aws_vpc.Prod-VPC.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "eu-west-2b"
  tags = {
    Name = "Prod-priv-sub1"
    Environment = "Test"
  }
}


# creating private subnet2
resource "aws_subnet" "Prod-priv-sub2" {
  vpc_id     = aws_vpc.Prod-VPC.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "eu-west-2b"
  tags = {
    Name = "Prod-priv-sub2"
    Environment = "Test"
  }
}

# Creating a public route table

resource "aws_route_table" "Prod-pub-RT" {
  vpc_id = aws_vpc.Prod-VPC.id

  route = []

  tags = {
    Name = "Prod-pub-RT"
    Environment = "Test"
  }
}

# public route table association1

resource "aws_route_table_association" "Pub-sub-assoc1" {
  subnet_id      = aws_subnet.Prod-pub-sub1.id
  route_table_id = aws_route_table.Prod-pub-RT.id
}

# public route table association2

resource "aws_route_table_association" "Pub-sub-assoc2" {
  subnet_id      = aws_subnet.Prod-pub-sub2.id
  route_table_id = aws_route_table.Prod-pub-RT.id
}

# Creating a private route table

resource "aws_route_table" "Prod-priv-RT" {
  vpc_id = aws_vpc.Prod-VPC.id

  route = []

  tags = {
    Name = "Prod-priv-RT"
    Environment = "Test"
  }
}

# private route table association1

resource "aws_route_table_association" "Priv-sub-assoc1" {
  subnet_id      = aws_subnet.Prod-priv-sub1.id
  route_table_id = aws_route_table.Prod-priv-RT.id
}

# private route table association2

resource "aws_route_table_association" "Priv-sub-assoc2" {
  subnet_id      = aws_subnet.Prod-priv-sub2.id
  route_table_id = aws_route_table.Prod-priv-RT.id
}

# creating internet gateway

resource "aws_internet_gateway" "Prod-igw" {
  vpc_id = "${aws_vpc.Prod-VPC.id}"

  tags = {
    Name = "Prod-igw"
    Environment = "Test"
  }
}

# internet gateway association
resource "aws_route" "Prod-IGW-Association" {
  route_table_id            = aws_route_table.Prod-pub-RT.id
  gateway_id = aws_internet_gateway.Prod-igw.id
  destination_cidr_block    = "0.0.0.0/0"
}

# Elastic IP
resource "aws_eip" "Prod-eip" {
  
  vpc      = true
}

# creating a NAT Gateway

resource "aws_nat_gateway" "Prod-Nat-gateway" {
  allocation_id = aws_eip.Prod-eip.id
  subnet_id     = aws_subnet.Prod-priv-sub1.id

  tags = {
    Name = "Prod-Nat-gateway"
  }
}

# Association of NAT Gateway
resource "aws_route" "Prod-Nat-Association" {
  route_table_id            = aws_route_table.Prod-priv-RT.id
  gateway_id = aws_nat_gateway.Prod-Nat-gateway.id
  destination_cidr_block    = "0.0.0.0/0"
}