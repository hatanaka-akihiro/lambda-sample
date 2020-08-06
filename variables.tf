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
  default     = "myKintoneFunction"
}

variable "lambda_role_name" {
  type        = string
  description = "Name of IAM role for Lambda function."
  default     = "myKintoneFunction-role"
}

variable "kintone_domain" {
  type        = string
  description = "Your domain name of kintone such as: xxxxx.cybozu.com"
}

variable "kintone_api_token" {
  type        = string
  description = "API token of kintone application."
}

variable "kintone_app_id" {
  type        = number
  description = "App ID of kintone application."
}

variable "api_name" {
  type        = string
  description = "Name of API."
  default     = "myKintoneFunction-API"
}

variable "api_path" {
  type        = string
  description = "Path to the API."
  default     = "myKintoneFunction"
}

variable "api_stage" {
  type        = string
  description = "Name of the stage to deploy the API."
  default     = "default"
}