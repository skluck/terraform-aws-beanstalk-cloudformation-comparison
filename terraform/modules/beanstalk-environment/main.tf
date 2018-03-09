locals {
  is_windows_platform = "${substr(var.solution_stack_name, 0, 20) == "64bit Windows Server"}"
  product_env_name    = "${var.name}-${var.stage}"

  alb_security_groups = "${length(var.alb_additional_security_groups) == 0 ? "${var.alb_sg}" : "${var.alb_sg},${join(",", var.alb_additional_security_groups)}"}"
}

data "aws_vpc" "vpc" {
  id = "${var.vpc_id}"
}

# Service Role + Policy
data "aws_iam_role" "default_service_role" {
  name = "aws-elasticbeanstalk-service-role"
}

# EC2 Role + Policy
resource "aws_iam_role" "ec2" {
  name               = "${local.product_env_name}-ec2"
  assume_role_policy = "${file("${path.module}/files/iam_trust_relationships.json")}"
}

resource "aws_iam_instance_profile" "ec2" {
  name_prefix = "${local.product_env_name}-ec2-"
  role = "${aws_iam_role.ec2.name}"
}

resource "aws_iam_role_policy_attachment" "web-tier" {
  role       = "${aws_iam_role.ec2.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "worker-tier" {
  role       = "${aws_iam_role.ec2.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

resource "aws_iam_role_policy_attachment" "multi-container-platform" {
  role       = "${aws_iam_role.ec2.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}

resource "aws_iam_role_policy_attachment" "custom-platform" {
  role       = "${aws_iam_role.ec2.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkCustomPlatformforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ssm-ec2" {
  role       = "${aws_iam_role.ec2.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

# http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create_deploy_docker.container.console.html
# http://docs.aws.amazon.com/AmazonECR/latest/userguide/ecr_managed_policies.html#AmazonEC2ContainerRegistryReadOnly
resource "aws_iam_role_policy_attachment" "ecr-readonly" {
  role       = "${aws_iam_role.ec2.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# resource "aws_ssm_activation" "ec2" {
#   name               = "${local.product_env_name}"
#   iam_role           = "${aws_iam_role.ec2.id}"
#   registration_limit = "${var.autoscale_max}"
# }

module "sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "1.15.0"

  name        = "${local.product_env_name}-ec2-sg"
  description = "EC2 of Beanstalk - ${local.product_env_name}"
  vpc_id      = "${data.aws_vpc.vpc.id}"

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
#This is done automatically in the module
#  tags {
#    Name = "${local.product_env_name}"
#  }
}

# Full list of options:
# http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html#command-options-general-elasticbeanstalkmanagedactionsplatformupdate
resource "aws_elastic_beanstalk_environment" "default" {
  application = "${var.beanstalk_application}"
  name        = "${local.product_env_name}"

  tier                = "${var.tier}"
  solution_stack_name = "${var.solution_stack_name}"

  wait_for_ready_timeout = "${var.wait_for_ready_timeout}"

  tags {
    Name = "${local.product_env_name}"
  }

  ##############################################################################
  # Software
  ##############################################################################

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "StreamLogs"
    value     = "true"
  }
  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "DeleteOnTerminate"
    value     = "true"
  }
  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "RetentionInDays"
    value     = "14"
  }

  ##############################################################################
  # Instances
  ##############################################################################

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "${var.instance_type}"
  }

  ##############################################################################
  # Capacity - Auto Scaling Group
  ##############################################################################

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "LoadBalanced"
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "Availability Zones"
    value     = "Any 2"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "${var.autoscale_min}"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "${var.autoscale_max}"
  }

  ##############################################################################
  # Capacity - Scaling triggers
  ##############################################################################

  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "MeasureName"
    value     = "CPUUtilization"
  }
  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "Statistic"
    value     = "Average"
  }
  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "Unit"
    value     = "Percent"
  }
  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "LowerThreshold"
    value     = "${var.autoscale_lower_bound}"
  }
  setting {
    namespace = "aws:autoscaling:trigger"
    name      = "UpperThreshold"
    value     = "${var.autoscale_upper_bound}"
  }

  ##############################################################################
  # Load Balancer
  ##############################################################################

  setting {
    namespace = "aws:elbv2:listener:default"
    name      = "ListenerEnabled"
    value     = "${var.http_listener_enabled == "true" || var.load_balancer_ssl_certificate_arn == "" ? "true" : "false"}"
  }
  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "ListenerEnabled"
    value     = "${var.load_balancer_ssl_certificate_arn == "" ? "false" : "true"}"
  }
  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "Protocol"
    value     = "HTTPS"
  }
  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "SSLCertificateArns"
    value     = "${var.load_balancer_ssl_certificate_arn}"
  }

  ##############################################################################
  # Rolling updates and deployments
  ##############################################################################

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "DeploymentPolicy"
    value     = "${var.deploying_policy}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "BatchSizeType"
    value     = "Percentage"
  }
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "BatchSize"
    value     = "35"
  }
  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "RollingUpdateEnabled"
    value     = "${(var.deploying_policy == "AllAtOnce") ? "false" : "true"}"
  }
  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "RollingUpdateType"
    value     = "Health"
  }
  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "MinInstancesInService"
    value     = "1"
  }
  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "MaxBatchSize"
    value     = "${var.batch_update_size}"
  }

  ##############################################################################
  # Security
  ##############################################################################

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = "${data.aws_iam_role.default_service_role.name}"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "${aws_iam_instance_profile.ec2.name}"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = "${var.ssh_keypair_name}"
  }

  ##############################################################################
  # Monitoring
  ##############################################################################

  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = "${local.is_windows_platform ? "basic": "enhanced"}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application"
    name      = "Application Healthcheck URL"
    value     = "${var.healthcheck_path}"
  }
  # The Application Load Balancer health check does not take into account the Elastic Beanstalk health check path
  # http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/environments-cfg-applicationloadbalancer.html
  # http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/environments-cfg-applicationloadbalancer.html#alb-default-process.config
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "HealthCheckPath"
    value     = "${var.healthcheck_path}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Port"
    value     = "80"
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Protocol"
    value     = "HTTP"
  }

  ##############################################################################
  # Managed updates
  ##############################################################################

  setting {
    namespace = "aws:elasticbeanstalk:managedactions"
    name      = "ManagedActionsEnabled"
    value     = "${local.is_windows_platform ? "false": "true"}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:managedactions"
    name      = "PreferredStartTime"
    value     = "Sun:10:00"
  }
  setting {
    namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
    name      = "UpdateLevel"
    value     = "minor"
  }
  setting {
    namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
    name      = "InstanceRefreshEnabled"
    value     = "true"
  }

  ##############################################################################
  # Notifications
  ##############################################################################
  # empty for now


  ##############################################################################
  # Network
  ##############################################################################

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = "${var.vpc_id}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${join(",", var.instance_subnets)}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = "${join(",", var.load_balancer_subnets)}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = "${var.load_balancer_visibility}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "false"
  }
  setting {
    namespace = "aws:elbv2:loadbalancer"
    name      = "ManagedSecurityGroup"
    value     = "${var.alb_sg}"
  }
  setting {
    namespace = "aws:elbv2:loadbalancer"
    name      = "SecurityGroups"
    value     = "${local.alb_security_groups}"
  }
  # Override default SSH inbound rule so we can control it manually.
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SSHSourceRestriction"
    value     = "tcp,22,22,127.0.0.1/32"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = "${module.sg.this_security_group_id}"
  }

  ##############################################################################
  # Database
  ##############################################################################
  # empty for now
}

module "tld" {
  source = "../route53"

  enabled   = "${var.zone_name != "" ? "true" : "false"}"
  zone_name = "${var.zone_name}"
  name      = "${local.product_env_name}"
  records   = ["${aws_elastic_beanstalk_environment.default.cname}"]
}
