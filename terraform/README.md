## Terraform - AWS Elastic Beanstalk - Infrastructure as Code

This package allows you to simply start up or tear down an **Elastic Beanstalk** application in AWS.

See [main.yaml](main.yaml) for main Terraform template file.

Modules
- [beanstalk-application](modules/beanstalk-application)
- [beanstalk-environment](modules/beanstalk-environment)
- [route53](modules/route53)

# Getting Started

## Pre reqs

- Terraform >= `0.11`

## Installation

1. Clone or download this repository
2. Fill in the configuration vars in `terraform.tfvars`.
    - See [terraform.tfvars.template](terraform.tfvars.template) for example file.
3. Run `terraform init`
4. Run `terraform plan`
5. Run `terraform apply`

> **NOTE** - This set up does not use workspaces or remote state - which are **CRITICAL** to using terraform
> in a safe manner. Do not use this in production without using workspaces and remote state.

## Configuration

To configure the cluster that terraform will create, simply fill out the terraform.tfvars file.
The following are all required vars unless specified with defaults:

| Var                                      | Description
| ---------------------------------------- | -----------
| aws_region                               | Region where instances get created
| ---                                      | ---
| application_name                         | Name for the application
| application_id                           | A unique application ID
| environment_name                         | Application environment such as `dev` or `prod`
| ---                                      | ---
| beanstalk_platform                       | Defaults to `php7`
| beanstalk_tier                           | Defaults to `web`
| instance_type                            | Defaults to `t2.micro`
| custom_beanstalk_platform                | Only use if you want to customize exact solution stack
| ssh_keypair_name                         | Optional
| ---                                      | ---
| healthcheck_path                         | Defaults to `/`
| ssl_certificate_arn                      | Optional
| ---                                      | ---
| deploying_policy                         | Defaults to `AllAtOnce`
| rolling_update_max_batch_size            | Defaults to `1`
| ---                                      | ---
| asg_min_instances                        | Defaults to `1`
| asg_max_instances                        | Defaults to `3`
| asg_trigger_lower_threshold              | Defaults to `20`
| asg_trigger_higher_threshold             | Defaults to `80`
| ---                                      | ---
| vpc_id                                   | VPC ID
| subnets_private_instances                | Public subnets for ALB (specify at least 2)
| subnets_public_load_balancer             | Private subnets for ASG (specify at least 2)
| load_balancer_visibility                 | Defaults to `internal`
| load_balancer_allowed_incoming_ip_or_sg  | Defaults to `0.0.0.0/0`
| load_balancer_additional_sg              | Optional.
| ---                                      | ---
| dns_zone_name                            | Optional. Enter to create DNS record.

## Example Usage

Output after `terraform apply` is run:

![Terraform Output](docs/apply_output.png)
