output "name" {
  value       = "${aws_elastic_beanstalk_environment.default.name}"
  description = "Name"
}

output "security_group_id" {
  value       = "${module.sg.this_security_group_id}"
  description = "Security group ID"
}

output "host" {
  value       = "${module.tld.hostname}"
  description = "DNS hostname"
}

output "alb_dns_name" {
  value       = "${aws_elastic_beanstalk_environment.default.cname}"
  description = "ALB hostname"
}

output "ec2_instance_profile_role_name" {
  value       = "${aws_iam_role.ec2.name}"
  description = "Instance IAM role name"
}
