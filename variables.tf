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

variable "api_name" {
  type        = string
  description = "Name of API."
  default     = "myLambdaFunction-API"
}

variable "api_path" {
  type        = string
  description = "Path to the API."
  default     = "myLambdaFunction"
}

variable "api_stage" {
  type        = string
  description = "Name of the stage to deploy the API."
  default     = "default"
}

variable "environment" {
  type = map
  default = {}
}