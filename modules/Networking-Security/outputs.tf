# output "instance_publicip" {
#   value       = aws_instance.vpc_ec2.public_ip
#   description = "Public IP of the EC2 instance provisioned"
# }

# output "vpc-id" {
#   value       = aws_vpc.myvpc.id
#   description = "CIDR value of the VPC that will be provisoned"
# }
# output "public_subnet_ids" {

#   value = [for s in data.aws_subnet.public : s.id]

# }
output "app_instance_sg_op" {
  value = aws_security_group.App-tier-instance-sg.id
}

output "aws_subnets" {
  value = aws_subnet.subnets[*].id
}

output "vpc_id_op" {
  value = aws_vpc.myvpc.id
}


output "app_subnet_id_op" {
  value = data.aws_subnet.subnet3.id
}

output "DBSGID" {
  value = aws_security_group.DB-instance-sg.id
}