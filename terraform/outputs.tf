data "aws_instance" "mauve" {
  instance_id = aws_instance.mauve.id
}

output "bastion_public_ip" {
  value = aws_instance.mauve-bastion.public_ip
}

output "webserver_private_ip" {
  value = data.aws_instance.mauve.private_ip
}

output "lb_dns_name" {
  value = aws_elb.mauve.dns_name
}
