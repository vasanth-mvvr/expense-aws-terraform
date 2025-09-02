resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  instance_tenancy = var.instance_tenancy
  enable_dns_hostnames = var.enable_dns_hostnames

  tags =merge( 
    var.common_tags,
    var.vpc_tags ,
    {
        Name = local.Name
    }
  
  )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.igw_tags,
    {
        Name= local.Name
    }
  )
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = true
  cidr_block = var.public_subnet_cidrs[count.index]
  tags = merge(
    var.common_tags,
    var.public_subnet_tags,
    {
        Name = "${var.project}-public-${local.az_names[count.index]}"
    }
  )
}
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  availability_zone = local.az_names[count.index]
  cidr_block = var.private_subnet_cidrs[count.index]
    tags = merge(
    var.common_tags,
    var.private_subnet_tags,
    {
        Name = "${var.project}-private-${local.az_names[count.index]}"
    }
  )
}
resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidrs)
  vpc_id = aws_vpc.main.id
    availability_zone = local.az_names[count.index]
  cidr_block = var.database_subnet_cidrs[count.index]
  tags = merge(
    var.common_tags,
    var.database_subnet_tags,
    {
        Name = "${var.project}-database-${local.az_names[count.index]}"
    }
  )
}

resource "aws_db_subnet_group" "default" {
  name = local.Name
  subnet_ids = aws_subnet.database[*].id
}
resource "aws_eip" "eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id = aws_subnet.public[0].id
  depends_on = [ aws_internet_gateway.igw ]
  tags = merge(
    var.common_tags,
    {
        Name = local.Name
    }
  )
}
resource "aws_route_table" "public" {
   vpc_id = aws_vpc.main.id
     tags = merge(
    var.common_tags,
    {
        Name = "${local.Name}-public"
    }
  )
}

resource "aws_route_table" "private" {
   vpc_id = aws_vpc.main.id
     tags = merge(
    var.common_tags,
    {
        Name = "${local.Name}-private"
    }
  )
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id
     tags = merge(
    var.common_tags,
    {
        Name = "${local.Name}-database"
    }
  )  
}

resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}
resource "aws_route" "private" {
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.nat.id
}
resource "aws_route" "database" {
  route_table_id = aws_route_table.database.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  subnet_id = element(aws_subnet.public[*].id,count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)
  subnet_id = element(aws_subnet.private[*].id,count.index)
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidrs)
  subnet_id = element(aws_subnet.database[*].id,count.index)
  route_table_id = aws_route_table.database.id
}