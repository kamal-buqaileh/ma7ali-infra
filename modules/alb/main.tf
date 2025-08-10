# ALB (Application Load Balancer) module

# Security group for ALB
resource "aws_security_group" "alb" {
  name        = "${var.name}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  # HTTP inbound - Required for internet-facing ALB
  # tfsec:ignore:aws-ec2-no-public-ingress-sgr
  ingress {
    description = "HTTP from internet (redirects to HTTPS)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS inbound - Required for internet-facing ALB
  # tfsec:ignore:aws-ec2-no-public-ingress-sgr
  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Restricted outbound traffic - Only to VPC and specific ports
  egress {
    description = "HTTP to targets"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    description = "HTTPS to targets"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    description = "Custom application ports to targets"
    from_port   = 3000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-alb-sg"
  })
}

# Application Load Balancer - Internet-facing for public access
# tfsec:ignore:aws-elb-alb-not-public
resource "aws_lb" "this" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.subnet_ids

  enable_deletion_protection = var.enable_deletion_protection
  
  # Security: Drop invalid header fields to prevent header injection attacks
  drop_invalid_header_fields = true
  
  # Access logs (optional)
  dynamic "access_logs" {
    for_each = var.access_logs_enabled ? [1] : []
    content {
      bucket  = var.access_logs_bucket
      prefix  = var.access_logs_prefix
      enabled = true
    }
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}

# Default target group for health checks
resource "aws_lb_target_group" "default" {
  name     = "${var.name}-default-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = var.health_check_path
    matcher             = "200"
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  tags = merge(var.tags, {
    Name = "${var.name}-default-tg"
  })
}

# HTTP listener (redirects to HTTPS)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = var.tags
}

# HTTPS listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }

  tags = var.tags
}

# Additional target groups
resource "aws_lb_target_group" "additional" {
  for_each = var.target_groups

  name     = "${var.name}-${each.key}-tg"
  port     = each.value.port
  protocol = each.value.protocol
  vpc_id   = var.vpc_id

  health_check {
    enabled             = lookup(each.value, "health_check_enabled", true)
    healthy_threshold   = lookup(each.value, "healthy_threshold", 2)
    unhealthy_threshold = lookup(each.value, "unhealthy_threshold", 2)
    timeout             = lookup(each.value, "timeout", 5)
    interval            = lookup(each.value, "interval", 30)
    path                = lookup(each.value, "health_check_path", "/health")
    matcher             = lookup(each.value, "matcher", "200")
    port                = lookup(each.value, "health_check_port", "traffic-port")
    protocol            = lookup(each.value, "health_check_protocol", each.value.protocol)
  }

  tags = merge(var.tags, {
    Name = "${var.name}-${each.key}-tg"
  })
}

# Listener rules for additional target groups
resource "aws_lb_listener_rule" "additional" {
  for_each = var.target_groups

  listener_arn = aws_lb_listener.https.arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.additional[each.key].arn
  }

  condition {
    host_header {
      values = each.value.host_headers
    }
  }

  tags = var.tags
}
