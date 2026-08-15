data "aws_route53_zone" "main" {

    name = "cloudfi.shop"
    private_zone = false

}

data "aws_lb" "alb" {
  name = "k8s-flightre-flightre-0e178945d1"
}

resource "aws_route53_record" "frontend" {

  zone_id = data.aws_route53_zone.main.zone_id
  name    = "cloudfi.shop"
  type    = "A"

  alias {

    name                   = aws_cloudfront_distribution.frontend.domain_name
    zone_id                = aws_cloudfront_distribution.frontend.hosted_zone_id
    evaluate_target_health = false

  }
}


resource "aws_route53_record" "backend" {
    zone_id = data.aws_route53_zone.main.zone_id
    name = "api.cloudfi.shop"
    type = "A"

    alias {
        name = data.aws_lb.alb.dns_name
        zone_id = data.aws_lb.alb.zone_id
        evaluate_target_health = true
    }
}