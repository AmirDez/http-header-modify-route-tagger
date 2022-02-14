output "BackendOriginEndpoint" {
  value = data.aws_instance.web_server.public_dns
}

output "CloudFrontEndpoint" {
  value = aws_cloudfront_distribution.website_cdn_root.domain_name
}