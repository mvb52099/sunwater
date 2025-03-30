resource "aws_route53_zone" "primary" {
  name = "mvb5209.space"
}

resource "aws_route53_record" "alb" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "terraform.mvb5209.space"   
  type    = "A"

  alias {
    name = aws_lb.application-lb.dns_name
    zone_id = aws_lb.application-lb.zone_id
    evaluate_target_health = true
  }
}