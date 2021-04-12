data "aws_ami" "ubuntu_2004_latest" {
  # Canonical, presumably.
  owners = ["099720109477"]
  most_recent = true
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


provider "aws" {
  profile = "default"
  region  = "ap-southeast-1"    # Change this to your preferred region
}

resource "aws_instance" "terraform_node" {
  ami           = data.aws_ami.ubuntu_2004_latest.id
  instance_type = "t2.micro"    # Change this to your preferred instance type
  subnet_id = aws_subnet.terraform_node.id
  vpc_security_group_ids = [aws_security_group.terraform_node.id]
  private_ip = "192.168.29.10"  # Change this to your preferred ip
  key_name = "terraform_node"

  tags = {
    Name = var.standard_tags.project
  }
}

output "terraform_node_public_ip" {
  value = aws_instance.terraform_node.public_ip
}


