variable "aws_access_key" {
  type        = string
  description = "AWS Access Key."
}
variable "aws_secret_key" {
  type        = string
  description = "AWS Secret Key."
}

####################
#        AWS       #
####################
variable "aws_region" {
  type        = string
  description = "AWS region."
}

####################
#        API       #
####################
variable "lambda_function_name" {
  type        = string
  description = "Name of Lambda function."
  default     = "myLambdaFunction"
}

variable "lambda_role_name" {
  type        = string
  description = "Name of IAM role for Lambda function."
  default     = "myLambdaFunction-role"
}