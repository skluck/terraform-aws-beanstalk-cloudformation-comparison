# AWS Elastic Beanstalk - Infrastructure as Code

### AWS Cloudformation vs Hashicorp Terraform

A comparison between CloudFormation and Terraform by creating an AWS Elastic Beanstalk app

- [cloudformation](cloudformation/)
- [terraform](terraform/)

The following resources must be created:
- Elastic Beanstalk Application
- Elastic Beanstalk Environment
- IAM Role
- IAM Instance Profile
- Load Balancer
- Security Group for Load Balancer
- Security Group for Beanstalk instances

Features needed:
- Create dynamic amount of environments (`1..n`)
- Ability to attach additional security groups
- Ability to add additional permissions or policies to IAM role
- Multiple AZ configurations (`1..3`)
- Simple HTTP or with HTTPS (Using AWS ACM certs)
- Public and private beanstalk environments
- Can control network ingress using CIDRs

#### Notes

Cloudformation
- tbd
- tbd

Terraform
- tbd
- tbd
