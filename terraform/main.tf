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

resource "aws_key_pair" "rmf_demo" {
  key_name = "rmf_demo"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCl0PU8HCYRawUdNyFDlIVLh4Eo+qYuasIgEPrjO1QR/QW4+zn8NzI4GhXFWe2p+FU8FuJ0lKryc1/7NLX/M3vndnqt4tMuZzJeIqNK8m+gHqwfxrNFBPy1l5IY/2iFctCsJL1YeL51y+wH1PZm7hSv90R8/eu+lp1kRQSTPySr8z3w9f7GmfhQvbRWiVzi+k5se3pZ/mxUb2KXwak8OJkMul00qpgFjHot4fDR4EG9ma2uedOB8Y9bdjIwJXHiMDmkH034OPXydGxv8Z2JHMrY7yeSOPFNb4+GoQ+gJXj+09pWAy6b3Q6QaKN7j5zSGVCOeyr4CdsKRt19M3CNlR0Tq/j7CQMCOz9VFuxUjendY8k3qx2gyaIxNBGx/qjBhvfhV/FHWmXdb1QlFNi/oFYo4w4Kj5gUxYLzvBqDNvcz5KYn3pnMS6mI53PdgewVCNvScVYYxUXzJIDwDT+UBj9B5IOmu7RknBwBrJ55XEgBJMNsXgCJ1zZ578lQ/dylRmGYGKMAON5JykNXv8Yk2bx42E+0WmiOx4rAVRTYYC2efl42cI3e+rNplSiq+aNz9BiGSEzetr7P16qNmsZRzyLVE8JmDR1H8uHRDC15CqgFFAmcGyy14zXT1BpeY+LsEBAe5yr5GnE+wg4b1lcUrTjmGF1XxOf/pbP2BA8vog/q/w== rmf_demo_deployment"
  tags = var.standard_tags
}

data "template_file" "user_data" {
  template = file("../scripts/wg_setup.yaml")
}

resource "aws_instance" "rmf_demo_server" {
  instance_type = "c5a.xlarge"
  ami = data.aws_ami.ubuntu_2004_latest.id
  subnet_id = aws_subnet.rmf_demo.id
  key_name = aws_key_pair.rmf_demo.id
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
