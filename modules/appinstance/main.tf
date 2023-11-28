########## App-tier-instance-Deployment #############

# data "aws_ami" "amzlinux2" {  most_recent = true  owners      = ["amazon"]   filter {    name   = "name"    values = ["amzn2-ami-hvm-*-x86_64-ebs"]  }}

# data "template_file" "user_data" {
#   template = file("D:/DevOps Projects/3-tier-arch-aws/Code/modules/appinstance/bootstrap.sh")
# }

data "aws_ssm_parameter" "rds_cluster_endpoint" {
  name = "/your-app/rds_cluster_endpoint"
} 

data "aws_instance" "instanceip" {
  filter {
    name   = "tag:Name"
    values = ["appinstance"] # Assuming your public subnet names match the tag "Name"
  }
}




data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"
    # values = ["amzn2-ami-hvm-*-x86_64-ebs"]
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }


  owners = ["amazon"] # Canonical
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
  key_name                    = "appkey"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = var.app_instance_sg
  iam_instance_profile        = var.ec2_profile_name
  associate_public_ip_address = false
  user_data = templatefile("${path.module}/user_data.tpl", {
    rds_cluster_endpoint = var.rds_cluster_endpoint,
    rds_master_username  = var.rds_master_username,
    rds_master_password  = var.rds_master_password


  })
  subnet_id = var.app_subnet_id_ip


  tags = {
    Name = "appinstance"
  }
}

resource "aws_key_pair" "appinstancekey" {
  key_name   = "appkey"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "tfkey" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "appkey.pem"
}

