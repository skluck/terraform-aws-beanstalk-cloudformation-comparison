variable "beanstalk_application" {
  description = "Beanstalk application name"
}

variable "name" {
  description = "Solution name, e.g. 'app' or 'jenkins'"
  default     = "app"
}

variable "stage" {
  description = "Stage, e.g. 'prod', 'staging', 'dev', or 'test'"
  default     = "dev"
}

# Software

variable "solution_stack_name" {
  description = "Elastic Beanstalk stack, e.g. Docker, Go, Node, Java, IIS. [Read more](http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/concepts.platforms.html)"
  default     = ""
}

variable "tier" {
  description = "Is this a web app or background worker? (WebServer or Worker)"
  default     = "WebServer"
}

variable "instance_type" {
  description = "Select the size of the instances to use in the ASG"
  default     = "t2.micro"
}

variable "ssh_keypair_name" {
  description = "Name of SSH key that will be deployed on Elastic Beanstalk and DataPipeline instance. The key should be present in AWS"
  default     = ""
}

# Load balancing

variable "healthcheck_path" {
  description = "Application Health Check URL. Elastic Beanstalk will call this URL to check the health of the application running on EC2 instances"
  default     = "/"
}

variable "load_balancer_ssl_certificate_arn" {
  description = "[Optional] SSL/TLS certificate ARN for the Load Balancer. Required to enable HTTPS."
  default     = ""
}

variable "alb_sg" {
  description = "ID of the security group used by the ALB"
}

variable "alb_additional_security_groups" {
  description = "Security groups to apply to ALB"
  default     = []
}

variable "http_listener_enabled" {
  description = "Enable port 80 on the instances (http)"
  default     = "false"
}

# Rolling deployments and managed updates

variable "deploying_policy" {
  description = "Deploy new versions or configuration changes to all instances at once or rolling?"
  default     = "AllAtOnce"
}

variable "batch_update_size" {
  description = "The maximum number of instances that can have configuration updated simultaneously"
  default     = "1"
}

# Auto scale

variable "autoscale_min" {
  description = "Minimum number of instances in the Auto Scaling group."
  default     = "1"
}

variable "autoscale_max" {
  description = "Maximum number of instances in the Auto Scaling group."
  default     = "3"
}

variable "autoscale_lower_bound" {
  description = "Minimum level of autoscale metric (percentage) to add instance"
  default     = "20"
}

variable "autoscale_upper_bound" {
  description = "Maximum level of autoscale metric (percentage) to remove instance"
  default     = "80"
}

# Network

variable "vpc_id" {
  description = "ID of the VPC in which to provision the AWS resources"
}

variable "instance_subnets" {
  description = "List of private subnets to place EC2 instances"
  type        = "list"
}

variable "load_balancer_subnets" {
  description = "List of private/public subnets to place Elastic Load Balancer"
  type        = "list"
}

variable "load_balancer_visibility" {
  description = "Is this application public or private? (external, internal)"
  default     = "external"
}

variable "zone_name" {
  description = "[Optional] Specify hosted zone name to create DNS record for the environment"
  default     = ""
}

# Other

variable "wait_for_ready_timeout" {
  default = "20m"
}
