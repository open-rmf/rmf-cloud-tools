#!/bin/bash
set -e

if [[ $EUID -ne 0 ]]; then
   echo -e "This script must be run as root"
   exit 1
fi

read -p "Install Ansible? [Yy] " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  apt update
  apt install software-properties-common -y
  apt-add-repository --yes --update ppa:ansible/ansible
  apt install ansible -y
  echo -e "\nAnsible Installed"
else
  echo -e "\nSkipping Ansible Install"
fi

read -p "Install Docker + Docker Compose? [Yy] " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  apt-get remove docker docker-engine docker.io containerd runc || true
  apt update
  apt install apt-transport-https ca-certificates curl gnupg lsb-release -y
  curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

  add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

  apt update
  apt install docker-ce docker-ce-cli containerd.io -y

  groupadd docker || true
  usermod -aG docker $USER

  curl -L "https://github.com/docker/compose/releases/download/1.29.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose

  echo -e "\nDocker and Docker Compose Installed"
else
  echo -e "\nSkipping Docker + Docker Compose Install"
fi

read -p "Install Terraform? [Yy] " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
  apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
  apt update
  apt install terraform -y
  echo -e "\nTerraform Installed"
else
  echo -e "\nSkipping Terraform Install"
fi

read -p "Install AWS CLI? [Yy] " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  ./aws/install
  rm awscliv2.zip
  echo -e "\nAWS CLI Installed"
else
  echo -e "\nSkipping AWS CLI Install"
fi
