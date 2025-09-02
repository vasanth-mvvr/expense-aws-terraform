data "aws_vpc" "default" {
  default = true
}

data "aws_availability_zones" "az" {
  state = "available"
}

# data "acceptor_vpc_id" "acceptor" {
  
# }

# data "aws_vpc" "default" {
#   default = true
# }
data "aws_route_table" "main" {
  vpc_id = data.aws_vpc.default.id
  filter {
    name = "association.main"
    values = ["true"]
  }
}