# TANELEER

This is the companion deployment project for [Taneleer Ruby](https://github.com/rabrown1975/taneleer-ruby).  The included example will deploy the companion application to AWS.  Object created include:

*  VPC
*  Internet Gateway
*  Routes
*  Subnets
*  Security Groups
*  Database and supporting objects.
*  Two or more VMs
*  Elastic Load Balancer

The example uses t2.micro instances.  Ruby is installed from source on each VM and it can take a while for the cloud-init to complete on the small instances.  

This project is for example purposes only and is not intended as a full production implementation.  For example, the database password is passed into the scripts as a variable, which will be stored in the terraform state.  In production, this would be pulled from a secure secret source, such as [Hashicorp Vault](https://www.vaultproject.io/).