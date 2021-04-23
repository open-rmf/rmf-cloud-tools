# provisioning

Tutorials on how to set up and connect various infrastructure for provisioning. 

## Initial Setup
On your device where you control provisioning, you will need to install the following:

* [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-ubuntu)
* [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli), if you want to provision cloud instances
* [Docker](https://docs.docker.com/engine/install/debian/), and [Docker Compose](https://docs.docker.com/compose/), if you want to provision local containers

An installation script is provided to install all the above on Ubuntu 20.04. You will need to run it as sudo.

Please check the script before running it to make sure it doesn't affect your local setup.

```
sudo bash setup/controller_init.bash 2>&1 | tee .logs_central_init
```

You should try to have ssh passwordless access for seamless Ansible Role provisioning. You can copy your ssh keys to the target devices:
```
ssh-copy-id [user]@[hostname]
```

## Local Devices
You might want to provision devices with certain roles using the Ansible roles provided. You will have to connect these devices on the same network somehow. Here are some ways:

### Use a Router
You can connect all your devices to a router. This would take care of most networking details for you. You can use `arp-scan` or `nmap` to reveal a list of IP addresses connected on your network.

For example, if my network interface was `eth0` ( you can check by running `ip a` ), you could run 
```
sudo arp-scan --interface=eth0 --localnet
```
which should pop up a list of devices in the same network:
```
Starting arp-scan 1.9.7 with 256 hosts (https://github.com/royhills/arp-scan)
192.168.50.1    d4:5d:64:86:67:6c       (Unknown)
192.168.50.49   16:fe:ed:fe:17:23       (Unknown: locally administered)
192.168.50.97   36:02:cb:48:80:cc       (Unknown: locally administered)

3 packets received by filter, 0 packets dropped by kernel
Ending arp-scan 1.9.7: 256 hosts scanned in 2.006 seconds (127.62 hosts/sec). 3 responded
```

### Use a Switch
You might not have a router but only a basic switch. In this case you connect all your devices to the swtich, and then set up a DHCP server on your device to serve DHCP IP addresses. There is a [script](/setup/controller_lan_setup.bash) to do this, with requires some (optional) configurations.
```
LAN_IFACE: The network interface on which your computer is connected to the network
LAN_DNS: The IP address that your hotspot will contact for DNS queries
LAN_CENTRAL_IP: The IP address that your device will have
LAN_SUBNET: The subnet mask of your network. Use the 255.255.255.0 notation
LAN_DHCP_LOW: The start ip of the DHCP pool
LAN_DHCP_HIGH: The end ip of the DHCP pool

# Examples
LAN_IFACE=enp3s0 bash controller_lan_setup.bash 
```

### Set up your computer as a Router
If you do not have a router, you can set up your current computer as a router using a hotspot. There is a [script](/setup/controller_hotspot_setup.bash) provided, which requires some (optional) configurations.
```
# All are optional with default parameters
LAN_IFACE: The network interface that you wish to operate the router hotspot on.
LAN_SSID: The SSID of the hotspot
LAN_PASSPHRASE: The passphrase of the hotspot
LAN_DNS: The IP address that your hotspot will contact for DNS queries
LAN_CENTRAL_IP: The IP address that your hotspot will have
LAN_SUBNET: The subnet mask of your network. Use the 255.255.255.0 notation
LAN_DHCP_LOW: The start ip of the DHCP pool
LAN_DHCP_HIGH: The end ip of the DHCP pool

# Examples
LAN_IFACE=enp3s0 bash controll_hotspot_setup.bash
LAN_IFACE=wlan0 LAN_SSID=hotspot LAN_PASSPHRASE=hunter2 bash controller_hotspot_setup.bash
```

### Use Static IP
The "simplest" solution. No matter how you are connected, if you have predetermined, static ips, you will be able to connect to those IP addresses directly.

## Docker "Devices"
For testing playbooks or various reasons, you might intend to set up a "cluster" of Docker images to simulate a real cluster of computers. We can simulate this setup by using [Docker Compose](https://docs.docker.com/compose/) to spin up a bunch of Docker containers. A more complex alternative is to use `Kubernetes`, which I will not go into as it becomes complex very quickly. There is a [script](/envs/docker_cluster/run) which helps to set up this Docker cluster.

The first thing you will need to do is to generate public/private keys, similar to how you would do it for your own [local devices](https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent). We will mount these keys on all containers in this docker cluster, so that passwordless ssh access is available. 

Run the following to generate the common ssh keys for your containers:
```
bash envs/docker_cluster/auth/generate
```

For simplicity, you can add the generated ssh key to your keyring:
```
ssh-agent bash
ssh-add envs/docker_cluster/auth/docker_cluster_id_rsa
```

Next, you can optionally build the basic docker image in this repository for use in the clusters. This image comes packed with a minimal setup of networking tools.
```
bash envs/docker_cluster/docker/build
```

Finally, we can fire up the clusters.
```
LAN_START_IP: The starting IP address where we generate the docker cluster. For example, 192.168.29.10
LAN_CONFIG: The CIDR notation representation of this network. For example, 192.169.29.0/24.
LAN_NODE_COUNT: The number of docker containers in this cluster
DOCKER_IMAGE: The docker image to use

# Examples
LAN_START_IP=192.168.29.10  LAN_CONFIG=192.168.29.0/24  LAN_NODE_COUNT=5  bash envs/docker_cluster/run
DOCKER_IMAGE=osrf/ros2:nightly bash envs/docker_cluster/run
```

You should now be able to ssh into devices as specified. If you added the ssh key into your keyring:
```
ssh root@192.168.29.10      # Replace the host IP with whatever your configuration is
```

Otherwise, you might need to specify the ssh key in your incantation:
```
ssh -i envs/docker_cluster/auth/docker_cluster_id_rsa root@192.168.29.10
```

## Cloud Devices
You might think of provisioning servers in the cloud. The possibilities are endless, but for illustration, we provide a basic [Terraform](https://www.terraform.io/) configuration to spin up an AWS instance. 


### AWS setup
You will first have to create an [Amazon Web Services](https://aws.amazon.com/free) account, capable of spinning up EC2 instances.

Next, install the [aws-cli v2](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html).

You will need to configure aws-cli with your credentials, so run `aws configure`.

### Terraform Setup
First, we will generate some credentials for our Terraform instance through AWS CLI:
```
bash envs/terraform_node/auth/generate
```

For simplicity, you can add the generated ssh key to your keyring:
```
ssh-agent bash
ssh-add envs/terraform_node/auth/terraform_node_id_rsa
```

We should modify the Terraform configuration files according to your unique scenario. Since Terraform has comprehensive documentation, it is better to refer [here](https://www.terraform.io/intro/index.html) for more information. For the configuration provided, we provision for the following features:

* EC2 instance, t2.micro, Ubuntu 20.04
* Cluster IP address `192.168.29.10` with configuration `192.168.29.0/24`
* Region `ap-southeast-1`
* Wireguard on port 51820
* Elastic ( Persistent across reboots ) IP

You can quickly configure various common aspects about this without going into too much detail about Terraform configuration by changing the input strings on the following commented lines:
```
grep -i -n "Change" envs/terraform_node/*.tf
```

When ready, fire it up:
```
bash envs/terraform_node/run
```

You can find information about your terraform instance in `envs/terraform_node/terraform_node_details`

You should now be able to ssh into devices as specified. If you added the ssh key into your keyring:
```
ssh ubuntu@[your-cloud-ip-address]      # Replace the host IP with whatever your configuration is
```

Otherwise, you might need to specify the ssh key in your incantation:
```
ssh -i envs/terraform_node/auth/terraform_node_id_rsa ubuntu@[your-cloud-ip-address]     
```
