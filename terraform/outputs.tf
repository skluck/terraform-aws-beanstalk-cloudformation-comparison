data "template_file" "output" {
  template = "${file("templates/output.tpl")}"

  vars {
    application_name = "${module.application.name}"
    environment_name = "${module.default_environment.name}"

    ec2_instance_profile_role_name = "${module.default_environment.ec2_instance_profile_role_name}"

    r53_dns_name = "${(module.default_environment.host != "") ? module.default_environment.host : "None used"}"
    alb_dns_name = "${module.default_environment.alb_dns_name}"

    alb_security_group_id = "${module.default_environment_alb_sg.this_security_group_id}"
    ec2_security_group_id = "${module.default_environment.security_group_id}"
  }
}

output "success_message" {
  value = "${data.template_file.output.rendered}"
}
