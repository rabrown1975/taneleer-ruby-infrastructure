output "aws_elb_dns_name" {
    description = "The DNS name assigned to the AWS ELB."
    value = aws_elb.elb.dns_name
}