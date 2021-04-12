resource "aws_vpc" "terraform_node" {
  cidr_block = "192.168.0.0/16"       # Change this to your preferred VPC settings
  tags = { Name = "terraform_node network" }
}

resource "aws_internet_gateway" "terraform_node" {
  vpc_id = aws_vpc.terraform_node.id
}

resource "aws_route" "outbound_via_igw" {
  route_table_id = aws_vpc.terraform_node.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.terraform_node.id
}

resource "aws_subnet" "terraform_node" {
  vpc_id = aws_vpc.terraform_node.id
  cidr_block = "192.168.29.0/24"      # Change this to your preferred subnet
  map_public_ip_on_launch = true
  tags = merge(var.standard_tags,
  { Name = "terraform_node_network" })
}

resource "aws_security_group" "terraform_node" {
  name = "terraform_node_network"
  description = "Hosts running on the terraform_node network"
  vpc_id = aws_vpc.terraform_node.id

  ingress {
    description = "WireGuard"         # Change the following settings to allow/block certain traffic
    from_port = 51820
    to_port = 51820
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = var.standard_tags
}

