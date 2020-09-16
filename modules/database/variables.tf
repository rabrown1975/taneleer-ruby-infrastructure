variable "prefix" {
    description = "The naming prefix for the network."
    type = string
}

variable "vpc_id" { 
    description = "The id of the VPC in which the DB instance will be created."
    type = string
}
variable "vpc_cidr" {
    description = "CIDR block for the VPC."
    type = string
}

variable "db_subnet_ids" {
    description = "The ids of the subnet(s) to include in the DB subnet group."
    type = set(string)
}
variable "db_size" {
    description = "The VM size for the database instance."
    type = string
}
variable "db_storage" {
    description = "The amount of storage in GB to attach to the database VM."
    type = number
}
variable "db_storage_type" {
    description = "The type of stortage to attach to the database VM."
    type = string
}
variable "db_engine" {
    description = "The database engine to use for this database instance."
    type = string
}
variable "db_engine_version" {
    description = "The version of the database engine."
    type = string
}
variable "db_name" {
    description = "The name of the database to create."
    type = string
}
variable "db_username" {
    description = "The username to configure for the database."
    type = string
}
variable "db_password" {
    description = "The password to configure for the database user.  This should not be done in a real production application."
    type = string
}