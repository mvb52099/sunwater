# Import self-signed certificate
resource "aws_acm_certificate" "self_signed" {
  private_key      = file("${path.module}/key.pem")
  certificate_body = file("${path.module}/cert.pem")
  tags = {
    Name = "self-signed-cert-mvb5209"
  }
}

# Create a security group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "alb-security-group"
  description = "Application load balancer security group"
  vpc_id      = aws_vpc.sunwater.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["24.126.15.224/32"]  # Replace with your actual IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-security-group"
  }
}


# Create a target group
resource "aws_lb_target_group" "alb-target-group" {
  name     = "application-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.sunwater.id

  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 10
    matcher             = 200
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 6
    unhealthy_threshold = 3
  }
}

# Attach the target group to the EC2 instance
resource "aws_lb_target_group_attachment" "attach-app" {
  target_group_arn = aws_lb_target_group.alb-target-group.arn
  target_id        = aws_instance.web-server.id
  port             = 80
}

# Create HTTPS listener for load balancer
resource "aws_lb_listener" "alb-https-listener" {
  load_balancer_arn = aws_lb.application-lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.self_signed.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-target-group.arn
  }
}


# Create HTTP listener for load balancer
resource "aws_lb_listener" "alb-http-listener" {
  load_balancer_arn = aws_lb.application-lb.arn
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
}


# Create the load balancer
resource "aws_lb" "application-lb" {
  name               = "mvb5209-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets = aws_subnet.public[*].id 
  enable_deletion_protection = false

  tags = {
    Environment = "mvb5209-alb"
    Name        = "production"
  }
}