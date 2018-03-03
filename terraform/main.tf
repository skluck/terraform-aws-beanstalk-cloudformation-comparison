resource "aws_elastic_beanstalk_application" "default" {
  name        = "${var.name}"
  description = "${var.description}"
}
