variable "standard_tags" {
  default = {
    project = "rmf_demo"
    environment = "development"
  }
  description = "Tags to be applied to all resources"
  type = map(string)
}

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

data "template_file" "user_data" {
  template = file("../scripts/wg_setup.yaml")
}

resource "aws_instance" "rmf_demo_server" {
  instance_type = "c5a.xlarge"
  ami = data.aws_ami.ubuntu_2004_latest.id
  subnet_id = aws_subnet.rmf_demo.id
  #key_name = aws_key_pair.rmf_demo.id
  root_block_device {
    volume_type = "gp2"
    volume_size = "500"
  }
  vpc_security_group_ids = [aws_security_group.rmf_demo.id]
  private_ip = "10.0.1.10"
  tags = merge(var.standard_tags,
  { Name = "RMF Demo - Server" })
  user_data = data.template_file.user_data.rendered
}

output "rmf_demo_server_public_ip" {
  value = aws_instance.rmf_demo_server.public_ip
}
