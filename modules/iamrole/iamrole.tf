# IAM policies for 



resource "aws_iam_policy" "ec2instances3policy" {
  name   = "${var.prefix}-${var.create_s3_policy}"
  policy = file("${path.module}/s3readaccess.json")
}

resource "aws_iam_policy" "ec2instancessmpolicy" {

  name   = "${var.prefix}-${var.create_ssm_policy}"
  policy = file("${path.module}/ssmpolicy.json")
}


# Create an IAM role
resource "aws_iam_role" "iamrole" {
  name               = "${var.prefix}-${var.role_name}"
  path               = "/system/"
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"

            },
            "Action": "sts:AssumeRole"
        }
    ]
}


EOF
}

resource "aws_iam_instance_profile" "threetierprofile" {
  name = "threetier-app-instance-profile"
  role = aws_iam_role.iamrole.name
}



# Attach the IAM policy to the IAM role
resource "aws_iam_policy_attachment" "ec2instances3_role_policy_attachment" {
  name       = "Policy Attachement"
  policy_arn = aws_iam_policy.ec2instances3policy.arn
  roles      = [aws_iam_role.iamrole.name]
}


# Attach the IAM policy to the IAM role
resource "aws_iam_policy_attachment" "ec2instancessm_role_policy_attachment" {
  name       = "Policy Attachement"
  policy_arn = aws_iam_policy.ec2instancessmpolicy.arn
  roles      = [aws_iam_role.iamrole.name]
}














# # Create an IAM instance profile
# resource "aws_iam_instance_profile" "jenkins_instance_profile" {
#   name = var.instance_profile_name
#   role = aws_iam_role.jenkins_role.name
# }