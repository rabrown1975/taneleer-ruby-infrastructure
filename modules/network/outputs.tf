output "vpc" {
    description = "The VPC created by this module."
    value = aws_vpc.vpc
}
output "subnets" {
    description = "The subnet(s) created by this module."
    value = aws_subnet.subnet
}