terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.92.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "myvpc" {
    cidr_block       = "10.0.0.0/16"
  
    tags = {
      Name = "demovpc"
    }
}

resource "aws_subnet" "pubsub" {
    vpc_id     = aws_vpc.myvpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
  
    tags = {
      Name = "sn1"
    }
  }

  resource "aws_subnet" "pubsub" {
    vpc_id     = aws_vpc.myvpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1a"
  
    tags = {
      Name = "sn1"
    }
  }

  resource "aws_subnet" "privatesub" {
    vpc_id     = aws_vpc.myvpc.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "us-east-1a"
  
    tags = {
      Name = "sn1"
    }
  }

  resource "aws_subnet" "privatesub" {
    vpc_id     = aws_vpc.myvpc.id
    cidr_block = "10.0.4.0/24"
    availability_zone = "us-east-1a"
  
    tags = {
      Name = "sn1"
    }
  }

  resource "aws_internet_gateway" "tfigw" {
    vpc_id = aws_vpc.myvpc.id
  
    tags = {
      Name = "tfigw"
    }
  }

  resource "aws_route_table" "tfpubrt" {
    vpc_id = aws_vpc.myvpc.id
  
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.tfigw.id
    }
  
    tags = {
      Name = "tfpublicroute"
    }
  }

  resource "aws_route_table_association" "pubsn1" {
    subnet_id      = aws_subnet.pubsub.id
    route_table_id = aws_route_table.tfpubrt.id
  }
  resource "aws_route_table_association" "pubsn2" {
    subnet_id      = aws_subnet.pub_sub.id
    route_table_id = aws_route_table.tfpubrt.id
  }

  resource "aws_eip" "tfeip" {
    domain   = "vpc"
  }

  resource "aws_nat_gateway" "tfnat" {
    allocation_id = aws_eip.tfeip.id
    subnet_id     = aws_subnet.pub_sub.id
  
    tags = {
      Name = "gw NAT"
    }
  }

  resource "aws_route_table" "tfprirt" {
    vpc_id = aws_vpc.myvpc.id
  
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway.tfnat.id
    }
  
    tags = {
      Name = "tfprivateroute"
    }
  }

  resource "aws_route_table_association" "prisn3" {
    subnet_id      = aws_subnet.prisub.id
    route_table_id = aws_route_table.tfprirt.id
  }
  resource "aws_route_table_association" "prisn4" {
    subnet_id      = aws_subnet.pri_sub.id
    route_table_id = aws_route_table.tfprirt.id
  }

  resource "aws_security_group" "allow_tfsg" {
    name        = "allow_tfsg"
    description = "Allow TLS inbound traffic"
    vpc_id      = aws_vpc.myvpc.id
  
    ingress {
      description      = "HTTPS "
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }
     ingress {
      description      = "HTTP "
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }
     ingress {
      description      = "SSH"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }
  
    egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
    }
  
    tags = {
      Name = "TfsecurityGroup"
    }
  }

  resource "aws_instance" "pub_ins" {
    ami                          = "ami-0fc5d935ebf8bc3bc"
    instance_type                = "t2.micro"
    subnet_id                    = aws_subnet.pub_sub.id
    vpc_security_group_ids        = [aws_security_group.allow_tfsg.id]
   key_name                      = "David"
   associate_public_ip_address =  "true"
  }

  resource "aws_instance" "pri_ins" {
    ami                          = "ami-0fc5d935ebf8bc3bc"
    instance_type                = "t2.micro"
    subnet_id                    =  aws_subnet.prisub.id
    vpc_security_group_ids        = [aws_security_group.allow_tfsg.id]
    key_name                = "David"
  }

