provider "aws" {
    region = "ap-northeast-1"
}
resource "aws_vpc" "myvpc" {
  cidr_block       = "10.10.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "myvpc"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "igw"
  }
}
# creting subnets 1,2 with diff az 
resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.10.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "ap-northeast-1a"

  tags = {
    Name = "public1"
  }
}
resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.10.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "ap-northeast-1c"

  tags = {
    Name = "public2"
  }
}
resource "aws_route_table" "rt1" {
    vpc_id = aws_vpc.myvpc.id
    route {
      cidr_block = "60.243.151.176/32"
      gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
      name = "rt1"
    }
}
resource "aws_route_table_association" "as1" {
    subnet_id      = aws_subnet.public1.id
    route_table_id = aws_route_table.rt1.id
}
resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.10.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "ap-northeast-1a"

  tags = {
    Name = "public2"
  }
}
resource "aws_route_table" "rt2" {
    vpc_id = aws_vpc.myvpc.id
    route {
      cidr_block = "60.243.151.176/32"
      gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
      name = "rt2"
    }
}
resource "aws_route_table_association" "as2" {
    subnet_id      = aws_subnet.public2.id
    route_table_id = aws_route_table.rt2.id
}
resource "aws_security_group" "mysecurity1" {
    name   = "mysecurity1"
    vpc_id = aws_vpc.myvpc.id
  
    ingress {
      description = "ssh for vpc"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["60.243.151.176/32"]
    }
    ingress {
      description = "https for vpc"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["60.243.151.176/32"]
    }
    ingress {
      description = "http for vpc"
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["60.243.151.176/32"]
    }
    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  
    tags = {
      Name = "mysecurity1"
    }
}
resource "aws_instance" "myinstance1" {
    ami                    = "ami-0218d08a1f9dac831"
    subnet_id              = aws_subnet.public1.id
    vpc_security_group_ids = [aws_security_group.mysecurity1.id]
    key_name               = "tokyo"
    instance_type          = "t2.micro"
    tags = {
      Name = "instance1"
    }
}
resource "aws_instance" "myinstance2" {
    ami                    = "ami-0218d08a1f9dac831"
    subnet_id              = aws_subnet.public2.id
    vpc_security_group_ids = [aws_security_group.mysecurity1.id]
    key_name               = "tokyo"
    instance_type          = "t2.micro"
    tags = {
      Name = "instance2"
    }
}
