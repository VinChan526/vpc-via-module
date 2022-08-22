terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}


resource "aws_vpc" "VPC" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "demo__VPC"
  }
}

resource "aws_subnet" "publicsub" {
  vpc_id     = aws_vpc.VPC.id
  cidr_block = "192.168.1.0/24"

  tags = {
    Name = "publicsub"
  }
}

resource "aws_subnet" "privatesub" {
  vpc_id     = aws_vpc.VPC.id
  cidr_block = "192.168.3.0/24"

  tags = {
    Name = "privatesub"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "MYIGW"
  }
}

resource "aws_eip" "ip" {
  vpc      = true
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ip.id
  subnet_id     = aws_subnet.privatesub.id

  tags = {
    Name = "gw NAT"
  }
}

resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
    tags = {
    Name = "customroutetable"
  }
}

resource "aws_route_table" "rt2" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.ngw.id
  }
    tags = {
    Name = "maintable"
  }
}

resource "aws_route_table_association" "association_1" {
  subnet_id      = aws_subnet.publicsub.id
  route_table_id = aws_route_table.rt1.id
}

resource "aws_route_table_association" "association_2" {
  subnet_id      = aws_subnet.privatesub.id
  route_table_id = aws_route_table.rt2.id
}

resource "aws_security_group" "sg" {
  name        = "first-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.VPC.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.VPC.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "first-sg"
  }
}



