
variable "prefix" {
  description = "Prefix to use all the provisioned resources 1.0.4"
  type        = string
  default     = "3tier"
}

variable "manage_master_user_password" {
  type    = string
  default = "myDB123arch"
}

variable "master_password" {
  type    = string
  default = "myDB123arch"
}


variable "vpcsg" {
  type = string
}


variable "db_subnet_ids" {
  type    = list(string)
  default = ["Private-App-Subnet-AZ-2", "Private-DB-Subnet-AZ-1"]
}