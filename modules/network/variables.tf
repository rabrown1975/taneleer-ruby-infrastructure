variable "region" {
    description = "The AWS region in which to create the network."
    type = string
}
variable "prefix" {
    description = "The naming prefix for the network."
    type = string
}
variable "vpc_cidr" {
    description = "CIDR block for the VPC."
    type = string
}
variable "subnet_cidrs" {
    description = "CIDR blocks for all subnets."
    #type = map
}