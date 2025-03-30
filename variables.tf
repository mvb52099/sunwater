# define AWS Region
variable "region" {
  description = "This is aws region"
  type        = string
  default     = "us-east-1"
}

# define availability zones
variable "availability_zone" {
  description = "availability zones for the subnets"
  default     = ["us-east-1a", "us-east-1b"]
  type        = list(any)
}