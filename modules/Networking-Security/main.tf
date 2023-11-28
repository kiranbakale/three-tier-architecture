###########VPC##################
resource "aws_vpc" "myvpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.prefix}-${var.vpc_name}"
  }
}


# Set the output (this output will be used as a reference later from another module)


###########SUBNETS################
resource "aws_subnet" "subnets" {
  count             = length(var.subnet_names)
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 3, count.index)
  availability_zone = element(var.azs, count.index % 2)

  tags = {
    # Name      = var.private_subnet_names[count.index]
    Name      = "${var.prefix}${var.subnet_names[count.index]}"
    Terraform = "true"
  }
}


data "aws_subnets" "available" {
  filter {
    name   = "tag:Name"
    values = ["${var.vpc_name}"]
  }
}

###########INTERNET-GATEWAY################

resource "aws_internet_gateway" "myIgw" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "${var.prefix}-aws_internet_gateway"
  }

}



########## Elastic IP for the NAT Gateway ##############
resource "aws_eip" "Nat-Gateway-EIP1" {
  domain = "vpc"
  tags = {
    Name      = "${var.prefix}${var.elasticip[0]}"
    Terraform = "true"
  }

}
resource "aws_eip" "Nat-Gateway-EIP2" {
  domain = "vpc"
  tags = {
    Name      = "${var.prefix}${var.elasticip[1]}"
    Terraform = "true"
  }

}


############## Data-Blocks ################

data "aws_subnet" "subnet1" {
  depends_on = [aws_subnet.subnets]
  filter {
    name   = "tag:Name"
    values = ["3tierPublic-Web-Subnet-AZ-1"]
  }
}

data "aws_subnet" "subnet2" {
  depends_on = [aws_subnet.subnets]
  filter {
    name   = "tag:Name"
    values = ["3tierPublic-Web-Subnet-AZ-2"]
  }
}


data "aws_subnet" "subnet3" {
  depends_on = [aws_subnet.subnets]
  filter {
    name   = "tag:Name"
    values = ["3tierPrivate-App-Subnet-AZ-1"]
  }
}


data "aws_subnet" "subnet4" {
  depends_on = [aws_subnet.subnets]
  filter {
    name   = "tag:Name"
    values = ["3tierPrivate-App-Subnet-AZ-2"]
  }
}

########### NAT Gateway #######################


resource "aws_nat_gateway" "NAT_GATEWAY" {
  depends_on = [
    aws_eip.Nat-Gateway-EIP1
  ]

  # Allocating the Elastic IP to the NAT Gateway!
  allocation_id = aws_eip.Nat-Gateway-EIP1.id

  # Associating it in the Public Subnet!
  subnet_id = data.aws_subnet.subnet1.id
  tags = {
    Name = "${var.prefix}${var.nat-gateway[0]}"
  }
}

resource "aws_nat_gateway" "NAT_GATEWAY2" {
  depends_on = [
    aws_eip.Nat-Gateway-EIP2
  ]

  # Allocating the Elastic IP to the NAT Gateway!
  allocation_id = aws_eip.Nat-Gateway-EIP2.id

  # Associating it in the Public Subnet!
  subnet_id = data.aws_subnet.subnet2.id
  tags = {
    Name = "${var.prefix}${var.nat-gateway[1]}"
  }
}




# #  5 : route Tables for public subnet

resource "aws_route_table" "PublicRT" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myIgw.id

  }

  tags = {

    Name = "${var.prefix}${var.route-table[0]}"
  }

}


# Creating a resource for the Route Table Association!

resource "aws_route_table_association" "RT-IG-Association1" {
  # Public Subnet ID
  subnet_id = data.aws_subnet.subnet1.id
  #  Route Table ID
  route_table_id = aws_route_table.PublicRT.id
}
resource "aws_route_table_association" "RT-IG-Association2" {
  # Public Subnet ID
  subnet_id = data.aws_subnet.subnet1.id
  #  Route Table ID
  route_table_id = aws_route_table.PublicRT.id
}


# Creating a Route Table for the first Nat Gateway!
resource "aws_route_table" "NAT-Gateway-RT" {
  depends_on = [
    aws_nat_gateway.NAT_GATEWAY
  ]

  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT_GATEWAY.id
  }

  tags = {

    Name = "${var.prefix}${var.route-table[1]}"
  }

}


# Creating a Route Table for the Second Nat Gateway!
resource "aws_route_table" "NAT-Gateway-RT2" {
  depends_on = [
    aws_nat_gateway.NAT_GATEWAY2
  ]

  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT_GATEWAY2.id
  }


  tags = {

    Name = "${var.prefix}${var.route-table[2]}"
  }
}


# Creating an Route Table Association of the NAT Gateway route 
# table with the Private Subnet!
resource "aws_route_table_association" "Nat-Gateway-RT-Association" {
  depends_on = [
    aws_route_table.NAT-Gateway-RT
  ]

  #  Private Subnet ID for adding this route table to the DHCP server of Private subnet!
  subnet_id = data.aws_subnet.subnet3.id

  # Route Table ID
  route_table_id = aws_route_table.NAT-Gateway-RT.id
}



# Creating an Route Table Association of the  second NAT Gateway route 
# table with the Private Subnet!
resource "aws_route_table_association" "Nat-Gateway-RT-Association2" {
  depends_on = [
    aws_route_table.NAT-Gateway-RT2
  ]

  #  Private Subnet ID for adding this route table to the DHCP server of Private subnet!
  subnet_id = data.aws_subnet.subnet4.id

  # Route Table ID
  route_table_id = aws_route_table.NAT-Gateway-RT2.id
}





############## Retreieving public ip of the machine running terraform ##############

data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}



resource "aws_security_group" "internet-facing-lbsg" {
  name        = "internet-facing-lb-sg"
  description = "Allow HTTP inbound traffic for internet facing loadbalancer"
  vpc_id = aws_vpc.myvpc.id
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"] //source
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "${var.prefix}${var.security_groups[0]}"
  }
}


resource "aws_security_group" "web-tier-lbsg" {
  name        = "Web-tier-sg"
  description = "Allow traffic from internet facing loadbalancer and our ip"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"] //source
  }

  ingress {
    description     = "HTTP"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.internet-facing-lbsg.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "${var.prefix}${var.security_groups[1]}"
  }
}



resource "aws_security_group" "internal-lbsg" {
  name        = "internal-lb-sg"
  description = "allows HTTP type traffic from your public instance security group"
  vpc_id      = aws_vpc.myvpc.id
  ingress {
    description     = "HTTP"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.web-tier-lbsg.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "${var.prefix}${var.security_groups[2]}"
  }
}


resource "aws_security_group" "App-tier-instance-sg" {
  name        = "App-tier-instance-sg"
  description = "allow TCP type traffic on port 4000 from the internal load balancer security group, and own ip for testing"
  vpc_id      = aws_vpc.myvpc.id
  ingress {
    description     = "HTTP"
    from_port       = 4000
    to_port         = 4000
    protocol        = "tcp"
    security_groups = ["${aws_security_group.internal-lbsg.id}"]
  }

  ingress {
    description = "HTTP"
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"] //source
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"] //source
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "${var.prefix}${var.security_groups[3]}"
  }
}

resource "aws_security_group" "DB-instance-sg" {
  name        = "App-DB-sg"
  description = "allow TCP type traffic on port 4000 from the internal load balancer security group, and own ip for testing"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description     = "HTTP"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.App-tier-instance-sg.id}"]
  }



  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "${var.prefix}${var.security_groups[4]}"
  }
}

output "DB-instance-sg-id" {
  value = aws_security_group.App-tier-instance-sg.id
}










