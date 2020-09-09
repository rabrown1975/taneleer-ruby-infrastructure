variable "region" {}
variable "prefix" {}
variable "ssh_key" {}
variable "vpc_cidr" {}
variable "subnet_cidrs" {
    description = "The availablility zone and CIDR block for each subnet in the VPC."
    type = map
}
variable "db_size" {}
variable "db_storage" {}
variable "db_storage_type" {}
variable "db_engine" {}
variable "db_engine_version" {}
variable "db_name" {}
variable "db_username" {}
variable "db_password" {}
variable "instance_size" {}
variable "instance_storage" {}
variable "instance_storage_type" {}
variable "instance_ami" {}

provider "aws" {
    region = var.region
    profile = "default"
}

resource "aws_key_pair" "key" {
    key_name = "${var.prefix}-key"
    public_key = var.ssh_key
    tags = {
        Name = "${var.prefix}-key"
        instance = var.prefix
    }
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

resource "aws_security_group" "db_security_group" {
    name = "${var.prefix}-db-security-group"
    vpc_id = aws_vpc.vpc.id
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

resource "aws_security_group" "instance_security_group" {
    name = "${var.prefix}-instance-security-group"
    vpc_id = aws_vpc.vpc.id
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [var.vpc_cidr]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "${var.prefix}-instance-security-group"
        instance = var.prefix
    }
}

resource "aws_security_group" "elb_security_group" {
    name = "${var.prefix}-elb-security-group"
    vpc_id = aws_vpc.vpc.id
    ingress {
        from_port = 80
        to_port = 80
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "${var.prefix}-elb-security-group"
        instance = var.prefix
    }
}

resource "aws_db_subnet_group" "db_subnet_group" {
    name = "${var.prefix}-db-subnet"
    subnet_ids = values(aws_subnet.subnet).*.id
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

resource "aws_instance" "instance" {
    for_each = aws_subnet.subnet
    ami = var.instance_ami
    instance_type = var.instance_size
    availability_zone = "${var.region}${each.key}"
    vpc_security_group_ids = [aws_security_group.instance_security_group.id]
    subnet_id = each.value.id
    associate_public_ip_address = "true"
    key_name = aws_key_pair.key.key_name
    root_block_device {
        volume_type = var.instance_storage_type
        volume_size = var.instance_storage
    }
    user_data = <<-EOF
                #!/bin/bash
                apt-get update /dev/null
                apt-get upgrade -y /dev/null
                apt-get install -y git zlib1g-dev postgresql-client libpq-dev apt-transport-https lsb-release curl wget gnupg bison dpkg-dev libgdbm-dev
                apt-get install -y libssl-dev libreadline-dev autoconf build-essential libyaml-dev libreadline-dev libncurses5-dev libffi-dev
                DISTRO=$(lsb_release -c -s)
                curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
                echo "deb https://deb.nodesource.com/node_12.x $${DISTRO} main" > /etc/apt/sources.list.d/nodesource.list
                echo "deb-src https://deb.nodesource.com/node_12.x $${DISTRO} main" >> /etc/apt/sources.list.d/nodesource.list
                curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
                echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
                apt-get update > /dev/null
                apt-get install -y nodejs yarn
                
                addgroup --gid 1001 taneleer
                adduser --gid 1001 --uid 1001 --disabled-password --gecos "" taneleer

                ######   RUBY INSTALL   ######
                LANG=C.UTF-8
                RUBY_MAJOR=2.7
                RUBY_VERSION=2.7.1

                wget -O ruby.tar.xz "https://cache.ruby-lang.org/pub/ruby/$${RUBY_MAJOR%-rc}/ruby-$RUBY_VERSION.tar.xz"; 
                
                mkdir -p /usr/src/ruby; 
                tar -xJf ruby.tar.xz -C /usr/src/ruby --strip-components=1; 
                rm ruby.tar.xz; 
                
                cd /usr/src/ruby; 

                { 
                    echo '#define ENABLE_PATH_CHECK 0'; 
                    echo; 
                    cat file.c; 
                } > file.c.new; 
                mv file.c.new file.c; 
                
                autoconf; 
                gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; 
                ./configure \
                    --build="$gnuArch" \
                    --disable-install-doc \
                    --enable-shared \
                ; 
                make -j "$(nproc)"; 
                make install; 
                
                cd /; 
                rm -r /usr/src/ruby;

                GEM_HOME=/usr/local/bundle
                BUNDLE_SILENCE_ROOT_WARNING=1
                BUNDLE_APP_CONFIG=/usr/local/bundle
                PATH=/usr/local/bundle/bin:$PATH
                mkdir -p "$GEM_HOME"
                chmod 777 "$GEM_HOME"
                echo "export GEM_HOME=/usr/local/bundle" >> /etc/profile
                echo "export BUNDLE_SILENCE_ROOT_WARNING=1" >> /etc/profile
                echo "export BUNDLE_APP_CONFIG=$GEM_HOME" >> /etc/profile
                echo "export PATH=$GEM_HOME/bin:$PATH" >> /etc/profile
                ######   RUBY INSTALL   ######

                mkdir -p /usr/src
                git clone https://github.com/rabrown1975/taneleer-ruby.git /usr/src/taneleer
                
                cat <<- EOFX > /usr/src/taneleer/config/database.yml
                development:
                    adapter: postgresql
                    encoding: unicode
                    username: ${var.db_username}
                    password: "${var.db_password}"
                    host: "${aws_db_instance.db_instance.address}"
                    database: ${var.db_name}
                EOFX

                cd /usr/src/taneleer
                bundle install
                yarn install --check-files
                /usr/src/taneleer/bin/rails db:migrate RAILS_ENV=development
                chown -R taneleer:taneleer /usr/src/taneleer
                
                cat <<- EOFX > /etc/systemd/system/taneleer.service
                [Unit]
                Description=Taneleer Service
                After=network.target

                [Service]
                Type=simple
                User=taneleer
                WorkingDirectory=/usr/src/taneleer
                ExecStart=/usr/src/taneleer/bin/rails server -b 0.0.0.0 -p 3000
                Restart=on-failure
                [Install]
                WantedBy=multi-user.target
                EOFX

                systemctl enable taneleer
                systemctl start taneleer
                EOF
    tags = {
        Name = "${var.prefix}-instance-${each.key}"
        instance = var.prefix
    }
}

# output "instance" {
#     value = aws_instance.instance
# }

resource "aws_elb" "elb" {
    name = "${var.prefix}-elb"
    #availability_zones = values(aws_subnet.subnet).*.availability_zone
    subnets = values(aws_subnet.subnet).*.id
    security_groups = [aws_security_group.elb_security_group.id]
    listener {
        instance_port = 3000
        instance_protocol = "http"
        lb_port = 80
        lb_protocol = "http"
    }
    health_check {
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 3
        target              = "HTTP:3000/"
        interval            = 30
    }
    instances = values(aws_instance.instance).*.id
    tags = {
        Name = "${var.prefix}-elb"
        instance = var.prefix
    }
}

output "aws_elb" {
    value = aws_elb.elb.dns_name
}