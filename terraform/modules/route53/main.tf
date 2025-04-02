# Route53 Module for DNS Management

data "aws_route53_zone" "selected" {
  name = var.domain_name
}

resource "aws_route53_record" "status_page" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.subdomain
  type    = "CNAME"
  ttl     = var.ttl
  records = [var.lb_dns_name]
}
