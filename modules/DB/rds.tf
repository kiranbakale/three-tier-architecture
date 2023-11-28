
data "aws_subnet" "dbsgd1" {
  filter {
    name   = "tag:Name"
    values = ["3tierPrivate-DB-Subnet-AZ-1"]
  }
}

data "aws_subnet" "dbsgd2" {
  filter {
    name   = "tag:Name"
    values = ["3tierPrivate-DB-Subnet-AZ-2"]
  }
}


resource "aws_db_subnet_group" "dbsgd" {
  name       = "dbsg"
  subnet_ids = [data.aws_subnet.dbsgd1.id, data.aws_subnet.dbsgd2.id]

  tags = {
    Name = "My DB subnet group"
  }
}

output "dbs1" {
  value = aws_db_subnet_group.dbsgd.id
}
