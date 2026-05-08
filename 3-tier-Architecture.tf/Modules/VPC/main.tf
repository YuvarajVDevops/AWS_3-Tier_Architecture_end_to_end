#--------------VPC Configuration-----------------


resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = { Name = "${var.env}-vpc" }
}


#---------------Internet Gateway-------------------

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
    tags = { Name = "${var.env}-igw" }
  
}


#----------------Public Subnet-----------------------

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr)
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr[count.index]
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = { Name="${var.env}-public-subnet-${count.index + 1}" }
}


#--------------Private Subnet-------------------------

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidr)
  vpc_id = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = { Name="${var.env}-private-subnet-${count.index + 1}" }
}

#----------------DATABASE Subnet------------------------


resource "aws_subnet" "db" {
  count = length(var.db_subnet_cidr)
  vpc_id = aws_vpc.main.id
  cidr_block = var.db_subnet_cidr[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = { Name = "${var.env}-db-subnet-${count.index + 1}"}
}



#------------Elastic IP attachment for NAT GATEWAYS----------------


resource "aws_eip" "nat" {
  
  count = length(var.public_subnet_cidr)
  domain = "vpc"
  tags = { Name = "${var.env}-eip-${count.index + 1}" }
  depends_on = [ aws_internet_gateway.main ]
}


#--------NAT GATEWAYS (1 per AZ for HA)------------

resource "aws_nat_gateway" "main" {

count = length(var.public_subnet_cidr)
allocation_id = aws_eip.nat[count.index].id
subnet_id = aws_subnet.public[count.index].id
tags = { Name = "${var.env}-nat-${count.index + 1}" }
  depends_on = [ aws_internet_gateway.main ]
}


#------------PUBLIC ROUTE TABLE--------------

resource "aws_route_table" "public" {
  
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = { Name = "${var.env}-public-rt" }
}


#---------PRIVATE ROUTE TABLE----------------

resource "aws_route_table" "private" {
  
  count = length(var.private_subnet_cidr)
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }
  tags = {Name = "${var.env}-private-rt-${count.index + 1}" }
}


#------------DATABASE ROUTE TABLE-----------------------

resource "aws_route_table" "db" {

    vpc_id = aws_vpc.main.id
    tags = { Name = "${var.env}-db-rt" }
  
}


#----------------ROUTE TABLE ASSOCIATIONS-------------

resource "aws_route_table_association" "public" {
  
  count = length(var.public_subnet_cidr)
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  
  count = length(var.private_subnet_cidr)
  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}


resource "aws_route_table_association" "db" {
  
  count = length(var.db_subnet_cidr)
  subnet_id = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.db.id
}


#---------------SECURITY GROUP CONFIGURATIONS------------------

#-------ALB SECURITY GROUP----------------

resource "aws_security_group" "alb" {

    name = "${var.env}-alb-sg"
    description = "allow HTTP/S from inr=ternet"
    vpc_id = aws_vpc.main.id

#From port and to port defines the range of ports allowed for destination not source port and destination port

 ingress {
    description = "HTTP from internet"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
 }

 ingress {
    description = "HTTPS from internet"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
 }

 egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
 }

 tags = { Name = "${var.env}-alb-sg" }
}


#----------------APPLICATION EC2 SECURITY GROUP------------------

resource "aws_security_group" "app" {

    name = "${var.env}-app-sg"
    description = "allow traffic from alb and bastion only"
    vpc_id = aws_vpc.main.id

    ingress {
        description = "HTTP from ALB only"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = [aws_security_group.alb.id]
    }

    ingress {
        description = "SSH from Bastion only"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups = [aws_security_group.bastion.id]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]

    }

    tags = { Name = "${var.env}-app-sg"}
  
}


#--------------BASTION SECURITY GROUP--------------------

resource "aws_security_group" "bastion" {

    name = "${var.env}-bastion-sg"
    description = "allow SSH from my IP only"
    vpc_id = aws_vpc.main.id

    ingress {
        description = "SSH from public for admin access to APP EC2"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    tags = { Name = "${var.env}-bastion-sg" }

  
}


#-------------RDS SECURITY GROUP--------------------

resource "aws_security_group" "rds" {

    name = "${var.env}-rds-sg"
    description = "allow mysql query from app EC2 only"
    vpc_id = aws_vpc.main.id

    ingress {

        description = "mysql queries from app ec2"
        from_port = 3306
        to_port = 3306  
        protocol = "tcp"
        security_groups = [aws_security_group.app.id]
    }

    tags = { Name = "${var.env}-rds-sg" }
  
}


#---------------------Monitoring Security Group----------------------

resource "aws_security_group" "monitoring" {

    name = "${var.env}-monitoring-sg"
    description = "allow Prometheus and grafana to access"
    vpc_id = aws_vpc.main.id

    ingress { 
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] 
         }

    ingress { 
        from_port = 9090
         to_port = 9090
          protocol = "tcp"
           cidr_blocks = ["0.0.0.0/0"]  
           }

    ingress { 
        from_port = 3000
         to_port = 3000
          protocol = "tcp"
           cidr_blocks = ["0.0.0.0/0"]
             }

    ingress { 
        from_port = 9100
        to_port = 9100
        protocol = "tcp"
        cidr_blocks = [var.vpc_cidr]
         }

    egress { 
        from_port = 0
         to_port = 0
          protocol = "-1"
           cidr_blocks = ["0.0.0.0/0"]
             }

  tags = { Name = "${var.env}-monitoring-sg" }
}
