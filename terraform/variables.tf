variable "aws_region" {
  description = "Region where resources get created"
}

variable "application_name" {
  description = "Name for the application. Alphanumeric or (hyphen). Must begin with a letter and end with a letter or number."
}

variable "application_id" {
  description = "A unique application ID. Must be 6 alphanumeric characters."
}

variable "environment_name" {
  description = "Application environment"
  default     = "dev"
}

# Software

variable "beanstalk_platform" {
  description = "Beanstalk platform type (Solution Stack)"
  default     = "php7"
}

variable "custom_beanstalk_platform" {
  description = "Use a custom stack or specific solution stack version"
  default     = ""
}

variable "beanstalk_tier" {
  description = "Is this a web app or background worker?"
  default     = "web"
}

variable "instance_type" {
  description = "Select the size of the instances to use in the ASG"
  default     = "t2.micro"
}

variable "ssh_keypair_name" {
  description = "[Optional] Specify an EC2 keypair to allow SSH access."
  default     = ""
}

# Load balancing

variable "healthcheck_path" {
  description = "URL path to the healthcheck endpoint for the application"
  default     = "/"
}

variable "ssl_certificate_arn" {
  description = "[Optional] SSL/TLS certificate ARN for the Load Balancer. Required to enable HTTPS."
  default     = ""
}

# Rolling deployments and managed updates

variable "deploying_policy" {
  description = "Deploy new versions or configuration changes to all instances at once or rolling? (Use rolling for prod!)"
  default     = "AllAtOnce"
}

variable "rolling_update_max_batch_size" {
  description = "The maximum number of instances that can have configuration updated simultaneously (1-100)"
  default     = "1"
}

# Auto scale

variable "asg_min_instances" {
  description = "Minimum number of instances in the Auto Scaling group. (1-10000)"
  default     = "1"
}

variable "asg_max_instances" {
  description = "Maximum number of instances in the Auto Scaling group. (1-10000)"
  default     = "3"
}

variable "asg_trigger_lower_threshold" {
  description = "Once average CPU load hits this percentage, a running instance will be removed (1-100)"
  default     = "20"
}

variable "asg_trigger_higher_threshold" {
  description = "Once average CPU load hits this percentage, a running instance will be added (1-100)"
  default     = "80"
}

# Network

variable "vpc_id" {
  description = "Which VPC should this application be deployed in?"
}

variable "subnets_private_instances" {
  description = "Select 2 private subnets for instances"
  type        = "list"
}

variable "subnets_public_load_balancer" {
  description = "Select 2 private or public subnets for load balancers"
  type        = "list"
}

variable "load_balancer_visibility" {
  description = "Should the ALB allow access over the public internet? (internal or external)"
  default     = "internal"
}

variable "load_balancer_additional_sg" {
  description = "Attach additional security groups to the ALB"
  type        = "list"
  default     = []
}

variable "load_balancer_allowed_incoming_ip_or_sg" {
  description = "List of IP CIDR blocks which are allowed access over HTTP/S"
  type        = "list"
  default     = ["0.0.0.0/0"]
}

# DNS

variable "dns_zone_name" {
  description = "[Optional] Specify hosted zone name to create DNS record for the environment"
  default     = ""
}

# lookups

variable "available_tiers" {
  default = {
    web    = "WebServer"
    worker = "Worker"
  }
}
