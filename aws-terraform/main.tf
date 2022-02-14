provider "aws" {
  region = var.aws_region
  profile = var.aws_profile

  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true

  skip_requesting_account_id = false
}
resource "aws_cloudfront_distribution" "website_cdn_root" {

  enabled     = true
  price_class = "PriceClass_All"

  origin {
    origin_id   =  data.aws_instance.web_server.public_dns
    domain_name =  data.aws_instance.web_server.public_dns

    custom_origin_config {
      origin_protocol_policy = "http-only"
      http_port            = 80
      https_port           = 443
      origin_ssl_protocols = ["TLSv1.2", "TLSv1.1", "TLSv1"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["HEAD", "GET", "OPTIONS"]
    cached_methods   = ["HEAD", "GET", "OPTIONS"]
    target_origin_id =  data.aws_instance.web_server.public_dns

    min_ttl          = "0"
    default_ttl      = "300"
    max_ttl          = "1200"

   
    viewer_protocol_policy = "allow-all"
    compress               = true
    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
      headers = ["Access-Control-Request-Headers", "Access-Control-Request-Method", "Origin"]

    }

    response_headers_policy_id = aws_cloudfront_response_headers_policy.dez_simple_cors.id
   
    function_association {
      event_type = "viewer-request"
       function_arn = aws_cloudfront_function.add_route_tag.arn
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
  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 404
    response_page_path    = "/404.html"
    response_code         = 404
  }

  tags = {
    ManagedBy = "terraform"
    Changed   = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
  }

  lifecycle {
    ignore_changes = [
      tags["Changed"],
      viewer_certificate,
    ]
  }
}

resource "aws_cloudfront_function" "add_route_tag" {
  name    = "add_route_tag"
  runtime = "cloudfront-js-1.0"
  comment = "main-add-route-tag"
  publish = true
  code    = file("route-tag.js")
}


resource "aws_cloudfront_response_headers_policy" "dez_simple_cors" {
  name    = "dez-simple-cors-origin-policy"
  comment = "Policy for dez-simple-cors"

  cors_config {
    access_control_allow_credentials = false

    access_control_allow_headers {
      items = ["*"]
    }

    access_control_allow_methods {
      items = ["GET", "HEAD"]
    }

    access_control_allow_origins {
      items = ["*"]
    }

    origin_override = true
  }
}

data "aws_instance" "web_server" {
  instance_id = var.aws_webserver_ami
}
