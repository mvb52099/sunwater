# Create a security group for EC2 instance
resource "aws_security_group" "web-server" {
  name        = "allow_http_access"
  description = "allow http traffic from alb and ssh from vpc"
  vpc_id      = aws_vpc.sunwater.id

  ingress {
    description     = "HTTP traffic from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "web-server-sg"
  }
}
