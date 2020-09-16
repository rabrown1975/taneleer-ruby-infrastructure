terraform {
    required_version = ">= 0.13"
}

resource "aws_security_group" "db_security_group" {
    name = "${var.prefix}-db-security-group"
    vpc_id = var.vpc_id
    ingress {
        from_port = 5432
        to_port = 5432
        protocol = "tcp"
        cidr_blocks = [var.vpc_cidr]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "${var.prefix}-db-security-group"
        instance = var.prefix
    }
}

resource "aws_db_subnet_group" "db_subnet_group" {
    name = "${var.prefix}-db-subnet"
    subnet_ids = var.db_subnet_ids
    tags = {
        Name = "${var.prefix}-db-subnet"
        instance = var.prefix
    }
}

resource "aws_db_instance" "db_instance" {
    skip_final_snapshot = true
    allocated_storage = var.db_storage
    storage_type = var.db_storage_type
    engine = var.db_engine
    engine_version = var.db_engine_version
    instance_class = var.db_size
    name = var.db_name
    username = var.db_username
    password = var.db_password
    db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
    vpc_security_group_ids = [aws_security_group.db_security_group.id]
    tags = {
        Name = "${var.prefix}-db-instance"
        instance = var.prefix
    }
}
