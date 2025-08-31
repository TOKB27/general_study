# ======VPC======
resource "aws_vpc" "tf-vpc-01" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = "true"

  tags = {
    Name = "TF-VPC-01"
    Env = "TF-WORK"
  }
}

# ======Subnet======
resource "aws_subnet""tf-vpc-01-pub-01-a" {
  vpc_id     = aws_vpc.tf-vpc-01.id
  cidr_block = "192.168.0.0/24"
  availability_zone = "ap-northeast-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "TF-VPC-01-Pub-01-a"
    Env = "TF-WORK"
  }
}

resource "aws_subnet" "tf-vpc-01-pri-01-a" {
  vpc_id     = aws_vpc.tf-vpc-01.id
  cidr_block = "192.168.1.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "TF-VPC-01-Pri-01-a"
    Env = "TF-WORK"
  }
}

# ======IGW======
resource "aws_internet_gateway" "tf-vpc-01-igw-01" {
  vpc_id = aws_vpc.tf-vpc-01.id

  tags = {
    Name = "TF-VPC-01-IGW-01"
    Env = "TF-WORK"
  }
}

# ======RouteTable======
resource "aws_route_table" "tf-vpc-01-rtb-pub-01" {
  vpc_id = aws_vpc.tf-vpc-01.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-vpc-01-igw-01.id
  }

  tags = {
    Name = "TF-VPC-01-RTB-Pub-01"
    Env = "TF-WORK"
  }
}

resource "aws_route_table" "tf-vpc-01-rtb-pri-01" {
  vpc_id = aws_vpc.tf-vpc-01.id

  tags = {
    Name = "TF-VPC-01-RTB-Pri-01"
    Env = "TF-WORK"
  }
}

resource "aws_route_table_association" "tf-vpc-01-rtb-at-pub" {
  subnet_id = aws_subnet.tf-vpc-01-pub-01-a.id
  route_table_id = aws_route_table.tf-vpc-01-rtb-pub-01.id
}

resource "aws_route_table_association" "tf-vpc-01-rtb-at-pri" {
  subnet_id = aws_subnet.tf-vpc-01-pri-01-a.id
  route_table_id = aws_route_table.tf-vpc-01-rtb-pri-01.id
}
