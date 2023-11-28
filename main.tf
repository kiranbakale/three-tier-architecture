module "ec2instanceiamrole" {
  source            = "./modules/iamrole"
  create_ssm_policy = var.ssm_policy-name
  create_s3_policy  = var.s3_policy_name
  role_name         = var.iamrolename
}

module "threetiervpc" {
  source   = "./modules/Networking-Security"
  vpc_name = var.vpcname
}


module "db" {
  depends_on = [module.threetiervpc]
  source     = "./modules/DB"
  vpcsg      = module.threetiervpc.DB-instance-sg-id

}


data "aws_secretsmanager_secret_version" "creds" {
  secret_id = "rds-creds"
}

locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.creds.secret_string
  )
}


resource "aws_ssm_parameter" "rds_cluster_endpoint" {
  name  = "/your-app/rds_cluster_endpoint"
  type  = "String"
  value = module.rdsaurora.cluster_endpoint
}




module "rdsaurora" {
  depends_on                  = [module.db]
  source                      = "registry.terraform.io/terraform-aws-modules/rds-aurora/aws"
  name                        = "dbsg"
  engine                      = "aurora-mysql"
  manage_master_user_password = false //using this argument rds will use only following creds and will not use  secrets manager
  master_username             = local.db_creds.master_username
  master_password             = local.db_creds.master_password
  engine_version              = "8.0.mysql_aurora.3.04.0"
  database_name               = "tfmysql"
  subnets                     = ["${module.db.dbs1}"]
  vpc_security_group_ids      = ["${module.threetiervpc.DBSGID}"] # Replace with your security group ID(s)
  vpc_id                      = module.threetiervpc.vpc_id_op     # Replace with your VPC ID
  instances = {
    one = {
      publicly_accessible = false
      instance_class      = "db.t3.medium"
    }

    two = {
      publicly_accessible = false
      instance_class      = "db.t3.medium"
    }
  }
  skip_final_snapshot          = true
  backup_retention_period      = 2
  preferred_backup_window      = null
  preferred_maintenance_window = null
}






output "rds_writer_endpoint" {
  value = module.rdsaurora.cluster_endpoint
}


module "appinstance" {
  depends_on           = [module.rdsaurora]
  source               = "./modules/appinstance"
  app_instance_sg      = ["${module.threetiervpc.app_instance_sg_op}"]
  ec2_profile_name     = module.ec2instanceiamrole.threetierec2profile
  app_subnet_id_ip     = module.threetiervpc.app_subnet_id_op
  rds_cluster_endpoint = module.rdsaurora.cluster_endpoint
  rds_master_username  = module.rdsaurora.cluster_master_username
  rds_master_password  = module.rdsaurora.cluster_master_password

}







resource "aws_s3_bucket" "codebucket" {
  bucket = "my-tf-code-bucket"
  tags = {
    Name        = "Codebucket"
    Environment = "Dev"
  }
}
