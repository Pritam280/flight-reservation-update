/*
resource "aws_cloudfront_distribution" "frontend" {
    enabled = true

    origin {
        domain_name = aws_s3_bucket.flight_bucket.website_endpoint
        origin_id   = "flightFrontend"
        custom_origin_config {
            http_port = 80
            https_port = 443
            origin_protocol_policy = "http-only"

            origin_ssl_protocols = [
                "TLSv1.2"
            ]
        }
    }

    default_root_object = "index.html"

    default_cache_behavior {
        target_origin_id = "flightFrontend"
        viewer_protocol_policy = "redirect-to-https"

        allowed_methods = [
            "GET",
            "HEAD"
        ]

        cached_methods = [
            "GET",
            "HEAD"
        ]

        forwarded_values {
            query_string = false
            cookies {
                forward = "none"
            }
        }
    }

    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }

    viewer_certificate {
        cloudfront_default_certificate = true
    }
}
*/

#######################################
# CloudFront Origin Access Control
#######################################

resource "aws_cloudfront_origin_access_control" "flight_oac" {

  name                              = "flight-oac"
  description                       = "Origin Access Control for Flight Frontend"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

#######################################
# CloudFront Distribution
#######################################

resource "aws_cloudfront_distribution" "frontend" {

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  origin {

    domain_name = aws_s3_bucket.flight_bucket.bucket_regional_domain_name
    origin_id   = "flightFrontend"

    origin_access_control_id = aws_cloudfront_origin_access_control.flight_oac.id
  }

  default_cache_behavior {

    target_origin_id       = "flightFrontend"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = [
      "GET",
      "HEAD"
    ]

    cached_methods = [
      "GET",
      "HEAD"
    ]

    compress = true

    forwarded_values {

      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {

    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {

    cloudfront_default_certificate = true
  }

  tags = {
    Name = "flight-cloudfront"
  }
}