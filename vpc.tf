resource "aws_vpc" "project-bedrock-vpc" {
    cidr_block = "10.0.0.0/16"
}

# Public Subnet 1 - AZ a
resource "aws_subnet" "project-bedrock-subnet-public1" {
    vpc_id            = aws_vpc.project-bedrock-vpc.id
    cidr_block        = "10.0.32.0/20"
    availability_zone = "eu-west-2a"
    map_public_ip_on_launch = true
}

# Public Subnet 2 - AZ b
resource "aws_subnet" "project-bedrock-subnet-public2" {
    vpc_id            = aws_vpc.project-bedrock-vpc.id
    cidr_block        = "10.0.16.0/20"
    availability_zone = "eu-west-2b"
    map_public_ip_on_launch = true
}

# Private Subnet 1 - AZ a
resource "aws_subnet" "project-bedrock-subnet-private1" {
    vpc_id            = aws_vpc.project-bedrock-vpc.id
    cidr_block        = "10.0.128.0/20"
    availability_zone = "eu-west-2a"
    # supposed to be false but I unfortunately don't have a NAT gateway provisioned because of cost 
    map_public_ip_on_launch = true
}

# Private Subnet 2 - AZ b
resource "aws_subnet" "project-bedrock-subnet-private2" {
    vpc_id            = aws_vpc.project-bedrock-vpc.id
    cidr_block        = "10.0.144.0/20"
    availability_zone = "eu-west-2b"
    # supposed to be false but I unfortunately don't have a NAT gateway provisioned because of cost
    map_public_ip_on_launch = true
}

resource "aws_route_table" "project-bedrock-rtb-public" {
    vpc_id = aws_vpc.project-bedrock-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.project-bedrock-igw.id
    }
}

resource "aws_route_table_association" "project-bedrock-rtb-public1" {
    subnet_id      = aws_subnet.project-bedrock-subnet-public1.id
    route_table_id = aws_route_table.project-bedrock-rtb-public.id
}

resource "aws_route_table_association" "project-bedrock-rtb-public2" {
    subnet_id      = aws_subnet.project-bedrock-subnet-public2.id
    route_table_id = aws_route_table.project-bedrock-rtb-public.id
}

resource "aws_route_table" "project-bedrock-rtb-private" {
    vpc_id = aws_vpc.project-bedrock-vpc.id
}

resource "aws_route_table_association" "project-bedrock-rtb-private1" {
    subnet_id      = aws_subnet.project-bedrock-subnet-private1.id
    route_table_id = aws_route_table.project-bedrock-rtb-private.id
}

resource "aws_route_table_association" "project-bedrock-rtb-private2" {
    subnet_id      = aws_subnet.project-bedrock-subnet-private2.id
    route_table_id = aws_route_table.project-bedrock-rtb-private.id
}

resource "aws_internet_gateway" "project-bedrock-igw" {
    vpc_id = aws_vpc.project-bedrock-vpc.id
}