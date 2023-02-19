##################### VPC Creation ######################

resource "aws_vpc" "main-vpc" {
  
    cidr_block = var.vpc-cidrs
    tags = {
      Name = "Main-VPC"
    }

}


#################### 2 Public Subnets #####################

resource "aws_subnet" "public-Subnets" {

    vpc_id = aws_vpc.main-vpc.id
    cidr_block = var.public-cidr-subs[count.index]
    count = length(var.public-cidr-subs)
    availability_zone = var.AZ[count.index]   
    map_public_ip_on_launch = true 

    tags = {
      Name = "Public-Subnets"
    }

}



####################### 2 Private Subnets #########################

resource "aws_subnet" "private-Subnets" {

    vpc_id = aws_vpc.main-vpc.id
    cidr_block = var.private-cidr-subs[count.index]
    count = length(var.private-cidr-subs)
    availability_zone = var.AZ[count.index] 
    map_public_ip_on_launch = false
    tags = {
      Name = "Private-Subnet"
    }
}

 

##################### Internet Gateway ######################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main-vpc.id
}



#################### Elastic IP ######################

resource "aws_eip" "eip" {

  vpc = true
  depends_on = [
    aws_internet_gateway.igw
  ]


}


##################### NAT Gateway #########################

# Nat gateway to connect private subnets to the internet 

resource "aws_nat_gateway" "nat" {

    subnet_id =   aws_subnet.public-Subnets[0].id
    allocation_id = aws_eip.eip.id
    
}


################### Public Route Table to IGW #################

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.main-vpc.id
  route {
    cidr_block = var.public-traffic
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public" {
    count = length(aws_subnet.public-Subnets)
    subnet_id = aws_subnet.public-Subnets[count.index].id
    route_table_id = aws_route_table.public-rt.id
  
}



####################### Private Route Table to NAT ####################

resource "aws_route_table" "private-rt" {
    
    vpc_id = aws_vpc.main-vpc.id
    route {
        cidr_block = var.public-traffic
        nat_gateway_id = aws_nat_gateway.nat.id
    }
  
}


resource "aws_route_table_association" "private" {
    count = length(aws_subnet.private-Subnets)
    subnet_id = aws_subnet.private-Subnets[count.index].id 
    route_table_id = aws_route_table.private-rt.id
  
}