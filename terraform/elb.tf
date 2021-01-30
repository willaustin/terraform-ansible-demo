resource "aws_security_group" "mauve-elb" {
  name        = "mauve-elb"
  description = "Allow Http"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Http traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_elb" "mauve" {
  name = "mauve"

  subnets = module.vpc.public_subnets

  listener {
    instance_port     = 4567
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  # listener {
  #   instance_port      = 8000
  #   instance_protocol  = "http"
  #   lb_port            = 443
  #   lb_protocol        = "https"
  #   ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/certName"
  # }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:4567/"
    interval            = 30
  }

  instances                   = [aws_instance.mauve.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
  security_groups             = [aws_security_group.mauve-elb.id]

  tags = var.tags
}
