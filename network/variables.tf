variable "aws_region" {
  default = "us-east-2"
}

variable "project_name" {
  default = "consul"
}

variable "environment" {
  default = "sandbox"
}

variable "tier_private" {
  default = "private"
}

variable "tier_public" {
  default = "public"
}

variable "aws_availability_zone_1" {
  default = "us-east-2a"
}

variable "aws_availability_zone_2" {
  default = "us-east-2b"
}

variable "aws_availability_zone_3" {
  default = "us-east-2c"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr_1" {
  default = "10.0.1.0/24"
}

variable "public_subnet_cidr_2" {
  default = "10.0.2.0/24"
}

variable "public_subnet_cidr_3" {
  default = "10.0.3.0/24"
}

variable "private_subnet_cidr_1" {
  default = "10.0.4.0/24"
}

variable "private_subnet_cidr_2" {
  default = "10.0.5.0/24"
}

variable "private_subnet_cidr_3" {
  default = "10.0.6.0/24"
}

variable "all_cidrs" {
  default = "0.0.0.0/0"
}
