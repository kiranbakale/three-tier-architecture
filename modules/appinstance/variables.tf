variable "app_instance_sg" {
  type = list(string)
}

variable "ec2_profile_name" {
  type = string
}

variable "app_subnet_id_ip" {
  type = string
}


# variable "ec2_user_data" {
#   type = string
# }



variable "rds_cluster_endpoint" {
  type = string
}

variable "rds_master_username" {
  type = string
}

variable "rds_master_password" {
  type = string
}


# data "template_file" "user_data" {
#   template = <<-EOF
# #!/bin/bash -v
# echo "userdata-start"
# sudo apt-get update -y
# sudo apt-get install -y nginx > /tmp/nginx.log
# sudo service nginx start
# sudo apt install mysql-server -y
# echo "userdata-end"
# mysql "${module.rdsaurora.cluster_endpoint}" -u "${module.rdsaurora.master_username}" -p${module.rdsaurora.master_password}
# CREATE DATABASE webappdb
# SHOW DATABASES;
# USE webappdb;
# CREATE TABLE IF NOT EXISTS transactions(id INT NOT NULL AUTO_INCREMENT, amount DECIMAL(10,2), description VARCHAR(100), PRIMARY KEY(id));    
# SHOW TABLES;    
# INSERT INTO transactions (amount,description) VALUES ('400','groceries');   
# SELECT * FROM transactions;
# EOF

#   vars = {
#     rdsaurora = module.rdsaurora
#   }
# }

# output "user_data_script" {
#   value = data.template_file.user_data.rendered
# }
