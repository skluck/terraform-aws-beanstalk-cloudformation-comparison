locals {
  product_name     = "${var.application_name}-${var.application_id}"
  product_env_name = "${var.application_name}-${var.application_id}-${var.environment_name}"

  stacks_regex = {
    docker          = "64bit Amazon Linux 2017.09 (.*) running Docker 17.09.1-ce"
    "docker-esc"    = "64bit Amazon Linux 2017.09 (.*) running Multi-container Docker 17.09.1-ce (Generic)"
    dotnet          = "^64bit Windows Server 2016 (.*) running IIS 10.0$"
    "dotnet-wsc"    = "^64bit Windows Server Core 2016 (.*) running IIS 10.0$"
    php5            = "^64bit Amazon Linux (.*) running PHP 5.6$"
    php7            = "^64bit Amazon Linux (.*) running PHP 7.1$"
    "php7.0"        = "^64bit Amazon Linux (.*) running PHP 7.1$"
    nodejs          = "^64bit Amazon Linux (.*) running Node.js$"
    java8           = "^64bit Amazon Linux (.*) running Java 8$"
    "java8-tomcat8" = "^64bit Amazon Linux (.*) running Tomcat 8 Java 8$"
    go              = "^64bit Amazon Linux (.*) running Go 1.9$"
    "python2.7"     = "64bit Amazon Linux 2017.09 (.*)  running Python 2.7"
    python3         = "64bit Amazon Linux 2017.09 (.*) running Python 3.6"
  }

  solution_stack_name = "${(var.custom_beanstalk_platform != "") ? var.custom_beanstalk_platform : lookup(local.stacks_regex, var.beanstalk_platform)}"
}

data "aws_elastic_beanstalk_solution_stack" "target_stack" {
  most_recent = true
  name_regex  = "${local.solution_stack_name}"
}

# Configure the AWS Provider
provider "aws" {
  version = "~> 1.8"
  region  = "${var.aws_region}"
}

data "aws_vpc" "vpc" {
  id = "${var.vpc_id}"
}

# module "default_environment_label" {
#   source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.3.1"
#   namespace  = "${var.namespace}"
#   stage      = "${terraform.workspace}"
#   name       = "${var.aws_beanstalk_name}-${var.aws_beanstalk_environment_name}"
# }

module "application" {
  source = "./modules/beanstalk-application"
  name   = "${local.product_name}"
}

module "default_environment" {
  source = "./modules/beanstalk-environment"

  # beanstalk
  beanstalk_application = "${module.application.name}"
  name                  = "${local.product_name}"
  stage                 = "${var.environment_name}"
  tier                  = "${lookup(var.available_tiers, var.beanstalk_tier)}"

  ssh_keypair_name    = "${var.ssh_keypair_name}"
  solution_stack_name = "${data.aws_elastic_beanstalk_solution_stack.target_stack.name}"
  instance_type       = "${var.instance_type}"

  # load balancing
  healthcheck_path                  = "${var.healthcheck_path}"
  load_balancer_ssl_certificate_arn = "${var.ssl_certificate_arn}"
  alb_sg                            = "${module.default_environment_alb_sg.this_security_group_id}"
  alb_additional_security_groups    = ["${var.load_balancer_additional_sg}"]
  http_listener_enabled             = true

  # rolling updates
  deploying_policy  = "${var.deploying_policy}"
  batch_update_size = "${var.rolling_update_max_batch_size}"

  # auto scaling
  autoscale_min         = "${var.asg_min_instances}"
  autoscale_max         = "${var.asg_max_instances}"
  autoscale_lower_bound = "${var.asg_trigger_lower_threshold}"
  autoscale_upper_bound = "${var.asg_trigger_higher_threshold}"

  # network
  vpc_id                   = "${data.aws_vpc.vpc.id}"
  instance_subnets         = ["${var.subnets_private_instances}"]
  load_balancer_subnets    = ["${var.subnets_public_load_balancer}"]
  load_balancer_visibility = "${var.load_balancer_visibility}"
  zone_name                = "${var.dns_zone_name}"
}

# https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/1.15.0
module "default_environment_alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "1.15.0"

  name        = "${local.product_env_name}-alb-sg"
  description = "ALB of Beanstalk - ${local.product_env_name}"
  vpc_id      = "${data.aws_vpc.vpc.id}"

  ingress_cidr_blocks = ["${var.load_balancer_allowed_incoming_ip_or_sg}"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  egress_rules        = ["http-80-tcp"]

  tags {
    Name = "${local.product_env_name}"
  }
}
