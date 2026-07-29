 # DNS — Route 53 Health Check + Optional Alias Record
 # A health check monitors the ALB endpoint.  The hosted zone and
# alias record are only created when `create_dns_records = true`
# (i.e. you own a real domain).

 # Health Check (always created — monitors ALB availability)
 resource "aws_route53_health_check" "alb" {
  fqdn              = aws_lb.app.dns_name
  port              = var.alb_listener_port
  type              = "HTTP"
  resource_path     = var.health_check_path
  failure_threshold = 3
  request_interval  = 30

  tags = merge(var.tags, { Name = "${local.name}-alb-health-check" })
}

 # Hosted Zone (only when you own a domain)
 resource "aws_route53_zone" "app" {
  count = var.create_dns_records ? 1 : 0
  name  = var.domain_name

  tags = merge(var.tags, { Name = "${local.name}-hosted-zone" })
}

 # Alias Record (A → ALB)
 resource "aws_route53_record" "alb_alias" {
  count   = var.create_dns_records ? 1 : 0
  zone_id = var.hosted_zone_id != "" ? var.hosted_zone_id : aws_route53_zone.app[0].zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.app.dns_name
    zone_id                = aws_lb.app.zone_id
    evaluate_target_health = true
  }
}
