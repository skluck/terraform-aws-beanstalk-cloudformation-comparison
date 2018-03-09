data "aws_elastic_beanstalk_hosted_zone" "current" {}

data "aws_route53_zone" "hosted_zone" {
  count = "${var.enabled == "true" ? 1 : 0}"
  name  = "${var.zone_name}"
}

resource "aws_route53_record" "default" {
  count   = "${var.enabled == "true" ? 1 : 0}"
  zone_id = "${data.aws_route53_zone.hosted_zone.zone_id}"
  name    = "${var.name}"

  type = "A"

  alias {
    name                   = "${element(var.records, count.index)}"
    zone_id                = "${data.aws_elastic_beanstalk_hosted_zone.current.id}"
    evaluate_target_health = false
  }
}
