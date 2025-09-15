variable "region" {
  type    = string
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "secondary_cidr_block" {
  description = "The secondary CIDR block to associate with the VPC"
  type        = string
  default     = "100.1.0.0/16"  
}

variable "secondary_private_subnet_cidrs" {
  type    = list(string)
  default = ["100.1.1.0/24", "100.1.2.0/24"]
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}


variable "cluster_name" {
  type    = string
  default = "eks-temporal"
}

variable "db_username" {
  type    = string
}

variable "db_password" {
  type    = string
}

variable "rds_endpoint" {
  type    = string
}
variable "profile" {
  type    = string
}

variable "vpc_endpoints" {
  type    = list(string)
}


