resource "aws_key_pair" "deployer" {
  key_name = "deployer-key"

  # could also use file() function here to point to the pub key (versioned in this repo)
  public_key = "<replace with public key contents>"
}

resource "aws_instance" "mauve" {
  ami               = "ami-07dd19a7900a1f049" # Ubuntu Server 20.04
  instance_type     = "t2.micro"
  availability_zone = "us-west-2a"
  subnet_id         = module.vpc.private_subnets[0]
  key_name          = aws_key_pair.deployer.key_name
  user_data         = file("ansible.sh")

  tags = var.tags
}

resource "aws_security_group" "mauve-bastion" {
  name        = "mauve-bastion"
  description = "Allow SSH"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH from home or wherever"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["<replace with home or other ip or cidr>"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_instance" "mauve-bastion" {
  ami                    = "ami-07dd19a7900a1f049" # Ubuntu Server 20.04
  instance_type          = "t2.micro"
  availability_zone      = "us-west-2a"
  subnet_id              = module.vpc.public_subnets[0]
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [module.vpc.default_security_group_id, aws_security_group.mauve-bastion.id]
  tags                   = var.tags
}
