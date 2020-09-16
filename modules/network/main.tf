terraform {
    required_version = ">= 0.13"
}


resource "aws_vpc" "vpc" {
    cidr_block = var.vpc_cidr
    tags = {
        Name = "${var.prefix}-vpc"
        instance = var.prefix
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id
    tags = {
        Name = "${var.prefix}-internet-gateway"
        instance = var.prefix
    }
}

resource "aws_route_table" "route_table" {
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "${var.prefix}-route-table"
        instance = var.prefix
    }
}

resource "aws_main_route_table_association" "rta" {
    vpc_id = aws_vpc.vpc.id
    route_table_id = aws_route_table.route_table.id
}

resource "aws_subnet" "subnet" {
    for_each = var.subnet_cidrs
    vpc_id = aws_vpc.vpc.id
    cidr_block = each.value
    availability_zone = "${var.region}${each.key}"
    tags = {
        Name = "${var.prefix}-subnet-${each.key}"
        instance = var.prefix
    }
}