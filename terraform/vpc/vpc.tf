resource "aws_vpc" "VPC_cluster_kubernetes" {
  cidr_block           = var.vpcCIDRblock
  instance_tenancy     = var.instanceTenancy 
tags = {
    Name = "VPC Cluster Kubernetes"
}
} 

resource "aws_subnet" "Public_subnet" {
  vpc_id                  = aws_vpc.VPC_cluster_kubernetes.id
  cidr_block              = var.publicsCIDRblock
tags = {
   Name = "Public subnet"
}
}

resource "aws_internet_gateway" "IGW_teste" {
 vpc_id = aws_vpc.VPC_cluster_kubernetes.id
 tags = {
        Name = "Internet gateway teste"
}
} 

resource "aws_route_table" "Public_RT" {
 vpc_id = aws_vpc.VPC_cluster_kubernetes.id

 route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW_teste.id
  }

 tags = {
        Name = "Public Route table"
}
} 

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.Public_RT.id
  destination_cidr_block = var.publicdestCIDRblock
  gateway_id             = aws_internet_gateway.IGW_teste.id
}

resource "aws_route_table_association" "Public_association" {
  subnet_id      = aws_subnet.Public_subnet.id
  route_table_id = aws_route_table.Public_RT.id
}