module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "mauve"
  cidr = "10.0.0.0/16"

  # for the sake of this example I limited the AZs and subnets to one
  azs = [
    "us-west-2a",
    # "us-west-2b",
    # "us-west-2c"
  ]
  private_subnets = [
    "10.0.1.0/24",
    # "10.0.2.0/24",
    # "10.0.3.0/24"
  ]
  public_subnets = [
    "10.0.101.0/24",
    # "10.0.102.0/24",
    # "10.0.103.0/24"
  ]

  enable_nat_gateway = true

  manage_default_security_group = true

  default_security_group_egress = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  default_security_group_ingress = [
    {
      protocol  = -1
      self      = true
      from_port = 0
      to_port   = 0
    },
    {
      from_port       = 0
      to_port         = 0
      protocol        = -1
      security_groups = aws_security_group.mauve-elb.id
      description     = "Allow traffic from the Mauve ELB"
    }
  ]

  tags = var.tags
}
