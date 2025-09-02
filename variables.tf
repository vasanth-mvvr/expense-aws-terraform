
#####  COMMON TAGS #####
variable "common_tags" {
  type = map
  default = {
    Name = "expense"
    environment = "dev"
    Terraform = "true"
  }
}

variable "project" {
  type = string
  default = "expense"
}
variable "environment" {
  default = "dev"
}

#####  AWS VPC MAIN BLOCK ######
variable "vpc_cidr_block" {
  type = string
  default = "10.0.0.0/16"
}

variable "instance_tenancy" {
  type = string
  default = "default"
}

variable "enable_dns_hostnames" {
  type = bool
  default = true
}

variable "vpc_tags" {
  type = map
  default = {

  }
}

###  IGW tags ####
variable "igw_tags" {
  type = map
  default = {

  }
}

## public subnets ##

variable "public_subnet_cidrs" {
  validation {
  condition = length(var.public_subnet_cidrs) == 2
  error_message = "Plese ensure two public subnets"
  }
}
variable "public_subnet_tags" {
  type = map
  default = {

  }
}
## Private subnet

variable "private_subnet_cidrs" {
  validation {
  condition = length(var.private_subnet_cidrs) == 2
  error_message = "Plese ensure two private subnets"
  }
}
variable "private_subnet_tags" {
  type = map
  default = {
    
  }
}
## database subnet
variable "database_subnet_cidrs" {
  validation {
  condition = length(var.database_subnet_cidrs) == 2
  error_message = "Plese ensure two database subnets"
  }
}
variable "database_subnet_tags" {
  type = map
  default = {
    
  }
}

variable "is_peering_required" {
  type = bool
  default = true
}

variable "acceptor_vpc_id" {
  type = string
  default = ""
}