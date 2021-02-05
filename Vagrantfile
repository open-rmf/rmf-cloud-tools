# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "bento/ubuntu-20.04"
  config.vm.provision "shell", inline: <<-SHELL
    mkdir -p /etc/wireguard/
    mkdir -p /etc/fastrtps_cloud/
    cp /vagrant/wg0.conf /etc/wireguard/
    cp /vagrant/fastrtps.xml /etc/fastrtps_cloud/
    apt-get update -y
    apt-get install -y wireguard
    wg-quick up wg0
    systemctl enable wg-quick@wg0
    systemctl start wg-quick@wg0
  SHELL
end
