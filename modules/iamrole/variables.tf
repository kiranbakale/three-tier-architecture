# variable "iam_policy_ec2instances3policy_name" {
#     default = "ec2instances3policy"
#   type        = string
# }
# variable "ec2instancessmpolicy_name" {
#     default = "ec2instancessmpolicy"
#   type        = string
# }


variable "prefix" {
  description = "Prefix to use all the provisioned resources 1.0.4"
  type        = string
  default     = "3tier"
}

variable "create_ssm_policy" {
  description = "ssm policy name"
  type        = string
  default     = null
}

variable "create_s3_policy" {
  description = "s3 policy name"
  type        = string
  default     = null
}

variable "role_name" {
  description = "ec2 instance role name"
  type        = string
  default     = null
}