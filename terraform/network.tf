resource "aws_vpc" "rmf_demo" {
  cidr_block = "10.0.0.0/16"
  tags = merge(var.standard_tags,
  { Name = "RMF demo network" })
}

resource "aws_internet_gateway" "rmf_demo" {
  vpc_id = aws_vpc.rmf_demo.id
}

resource "aws_route" "outbound_via_igw" {
  route_table_id = aws_vpc.rmf_demo.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.rmf_demo.id
}

resource "aws_subnet" "rmf_demo" {
  vpc_id = aws_vpc.rmf_demo.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = merge(var.standard_tags,
  { Name = "RMF demo network" })
}

resource "aws_security_group" "rmf_demo" {
  name = "RMF Demo Server"
  description = "Hosts running the RMF demo server"
  vpc_id = aws_vpc.rmf_demo.id

  ingress {
    description = "WireGuard"
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


