#Declaring Variables for VPC module.

variable "env" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidr" {
  type = list(string)
}

variable "private_subnet_cidr" {
  type = list(string)
}

variable "db_subnet_cidr" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}