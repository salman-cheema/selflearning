locals {
  bastion_key_name   = "bastion-key"
}
resource "aws_key_pair" "deployer" {
  key_name   = local.bastion_key_name
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCrlmYCUmvuf/Uk+gdxwvCD6YLxnjusxi+6sBhP1wjbc/hJyzwXp2SmYhJ9/paVp2lQyrYU4PKOwm/Iz3pZ8eKSeYf6Za1Jir3bGGNs9wptcY03uJFtbKWvSnQBeBX7/7GVn4jN5wpnasXEKUD4QPht5uDwHB5O4YTpwiiIxgswGvcEYKXDnhwn/S8iBXRcT3njbze1G9e5BfNWVZXh0Vw40P1uOaGaYfjgPZq96ZLfrO6yr3D09LHO49YZ23MiLGo+ILTEKAd1tsdljEMUxEMOGPBixOzFjp7NRowVtNitCumFoMCAOuRMmXdAsv/szbR74a3Bor0hZLV3v/FbqLPt suleman@A003-00369"
}
# To let the users make coonection to private RDS
# Ideally it should be through VPN + transitgateway
module "ec2" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "3.2.0"
  name                   = "${local.env}-bastion"
  ami                    = "ami-09e67e426f25ce0d7"
  instance_type          = "t2.small"
  key_name               = local.bastion_key_name
  vpc_security_group_ids = [module.sg_ec2_bastion.security_group_id]
  subnet_id                   = element(module.vpc.public_subnets,0)
  user_data                   = data.template_cloudinit_config.config.rendered
  associate_public_ip_address = true
  depends_on = [ module.rds ]

}

data "template_file" "bastion_user_data" {
  template = file("../scripts/bastion-cloud-init.yml")
  vars = {
    ec2_hostname = "${local.env}-bastion"
    master_rds_username = module.master_rds_username.value
    master_rds_password = module.master_rds_password.value
    rds_host= module.rds_endpoint.value
    rates_rw_password = random_password.rates_rw_password.result
    rates_api_username = local.rates_api_username
    rates_api_db_name = local.rates_api_db_name
  }
}

# Render a multi-part cloud-init config making use of the part
data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true
  part {
    content = data.template_file.bastion_user_data.rendered
  }

}