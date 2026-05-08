#declaring variables for the Monitoring module

variable "env" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "keyname" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "monitoring_sg_id" {
  type = string
}

variable "vpc_cidr" {
  type = string
}