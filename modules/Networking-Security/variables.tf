variable "instance_type" {
  type        = string
  description = "instance type that will be used for instance"
  default     = "t2.nano"
}




variable "vpc_cidr" {
  type        = string
  description = "CIDR Value of the VPC"
  default     = "40.0.0.0/16"
}
variable "prefix" {
  description = "Prefix to use all the provisioned resources 1.0.4"
  type        = string
  default     = "3tier"
}


variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"] # Replace with your desired AZs
}

variable "vpc_name" {
  type    = string
  default = "3tier-vpc"
}

variable "elasticip" {
  type    = list(string)
  default = ["elastic-ip1", "elastic-ip2"]
}

# private subnets
variable "subnet_names" {
  type    = list(string)
  default = ["Private-App-Subnet-AZ-1", "Private-App-Subnet-AZ-2", "Private-DB-Subnet-AZ-1", "Private-DB-Subnet-AZ-2", "Public-Web-Subnet-AZ-1", "Public-Web-Subnet-AZ-2"]
}


variable "public_subnet_names1" {
  type    = list(string)
  default = ["Public-Web-Subnet-AZ-1"]
}

variable "public_subnet_names2" {
  type    = list(string)
  default = ["Public-Web-Subnet-AZ-2"]
}




variable "nat-gateway" {
  type    = list(string)
  default = ["NAT-GW-AZ1", "NAT-GW-AZ2"]

}

variable "route-table" {

  type    = list(string)
  default = ["Public-Web-RT", "Private-AZ1-RT", "Private-AZ2-RT"]

}





variable "security_groups" {

  type    = list(string)
  default = ["internet-facing-lb-sg", "Web-tier-sg", "internal-lb-sg", "App-tier-instance-sg", "App-DB-sg"]

}





