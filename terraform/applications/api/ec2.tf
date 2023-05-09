locals {
  bastion_key_name   = "bastion-key"
}
resource "aws_key_pair" "deployer" {
  key_name   = local.bastion_key_name
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}
module "ec2" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "3.2.0"
  name                   = "${local.env}-bastion"
  ami                    = "ami-09e67e426f25ce0d7"
  instance_type          = "t2.small"
  key_name               = local.bastion_key_name
  vpc_security_group_ids = module.sg_ec2_bastion.security_group_id
  subnet_id                   = element(module.vpc.public_subnets,0)
  user_data                   = data.template_cloudinit_config.config[each.value].rendered
  associate_public_ip_address = true

}