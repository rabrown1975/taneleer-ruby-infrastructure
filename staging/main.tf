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

module "network" {
    source = "../modules/network"
    region = var.region
    prefix = var.prefix
    vpc_cidr = var.vpc_cidr
    subnet_cidrs = var.subnet_cidrs
}

module "database" {
    source = "../modules/database"
    prefix = var.prefix
    vpc_id = module.network.vpc.id
    vpc_cidr = var.vpc_cidr
    db_subnet_ids = values(module.network.subnets).*.id
    db_size = var.db_size
    db_storage = var.db_storage
    db_storage_type = var.db_storage_type
    db_engine = var.db_engine
    db_engine_version = var.db_engine_version
    db_name = var.db_name
    db_username = var.db_username
    db_password = var.db_password
}

module "servers" {
    source = "../modules/servers"
    region = var.region
    prefix = var.prefix
    ssh_key = var.ssh_key
    vpc_id = module.network.vpc.id
    vpc_cidr = var.vpc_cidr
    # subnet_ids = values(module.network.subnets).*.id
    # subnet_cidrs = values(module.network.subnets).*.cidr_block
    subnets = module.network.subnets
    instance_size = var.instance_size
    instance_storage = var.instance_storage
    instance_storage_type = var.instance_storage_type
    instance_ami = var.instance_ami
    db_host = module.database.instance.address
    db_name = var.db_name
    db_username = var.db_username
    db_password = var.db_password
}

output "aws_elb_dns_name" { 
    description = "The DNS name assigned to the AWS ELB."
    value = module.servers.aws_elb_dns_name
}










