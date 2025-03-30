# create a vpc
resource "aws_vpc" "sunwater" {
  cidr_block           = "10.0.0.0/16"  # Changed to match requirements
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Name" = "Application-lb"
  }
}


# create public subnets
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.sunwater.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = element(var.availability_zone, count.index)
  map_public_ip_on_launch = true
  tags = {
    "Name" = "Application-lb-public-${count.index + 1}"
  }
}

# create private subnets
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.sunwater.id
  cidr_block        = "10.0.${count.index + 3}.0/24"
  availability_zone = element(var.availability_zone, count.index)
  tags = {
    "Name" = "Application-lb-private-${count.index + 1}"
  }
}

# create a route table
resource "aws_route_table" "sunwater-rt" {
  vpc_id = aws_vpc.sunwater.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    "Name" = "Application-lb-route-table"
  }
}

# create a route table association for private subnets
resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.sunwater-rt.id
}

# create an internet gateway
resource "aws_internet_gateway" "sunwater-igw" {
  vpc_id = aws_vpc.sunwater.id
  tags = {
    "Name" = "Application-lb-gateway"
  }
}

# create an internet route
resource "aws_route" "internet-route" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.sunwater-rt.id
  gateway_id             = aws_internet_gateway.sunwater-igw.id
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id  
}