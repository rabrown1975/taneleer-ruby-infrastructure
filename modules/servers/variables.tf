variable "region" {
    description = "The AWS region in which to create the VMs."
    type = string
}
variable "prefix" {
    description = "The naming prefix for the network."
    type = string
}
variable "ssh_key" {
    description = "The public SSH key to associate with each VM created."
}

variable "vpc_id" { 
    description = "The id of the VPC in which the DB instance will be created."
    type = string
}
variable "vpc_cidr" {
    description = "CIDR block for the VPC."
    type = string
}
# variable "subnet_ids" {
#     description = "The ids of the subnet(s) to include in the DB subnet group."
#     type = set(string)
# }
# variable "subnet_cidrs" {
#     description = "CIDR blocks for all subnets."
#     type = set(string)
# }

variable "subnets" {
    description = "The subnets for the VMs."
}

variable "instance_size" {
    description = "The VM size for each instance."
    type = string
}
variable "instance_storage" {
    description = "The amount of storage in GB to attach to the each VM."
    type = number
}
variable "instance_storage_type" {
    description = "The type of stortage to attach to the each VM."
    type = string
}
variable "instance_ami" {
    description = "The AWS AMI id used to create each VM."
    type = string
}

variable "db_host" {
    description = "The host address for the database."
    type = string
}
variable "db_name" {
    description = "The name of the database."
    type = string
}
variable "db_username" {
    description = "The username for the database."
    type = string
}
variable "db_password" {
    description = "The password for the database user.  This should not be done in a real production application."
    type = string
}