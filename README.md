# rmf-cloud-tools

Various automated hardware-in-the-loop setups and demos, using [Red Hat Ansible](https://www.ansible.com/).


## Required Setup
The following documents a few ways to quickly get things up and running. For running the examples in this repo, there are provided `docker-compose` setups that take care of the Networking and Deploy Setups for you, so only the Central setup is required. Have a look a the [envs](envs) folder for more details.

### Central Setup
On your Ansible device where you control deployment (we will call it `central` for convention):

* [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-ubuntu)
* [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli), if you want to run the provided demo cloud infrastructure.
* [Docker](https://docs.docker.com/engine/install/debian/) and [Docker Compose](https://docs.docker.com/compose/install/), if you want to run the provided local infrastructure. Remember to run the [post-install steps](https://docs.docker.com/engine/install/linux-postinstall/).

An [installation script](setup/central_init.bash) is provided to install all the above on Ubuntu 20.04. You will need to run it as `sudo`. 

*Please check the script before running it to make sure it doesn't affect your local setup.*

```
sudo bash setup/central_init.bash 2>&1 | tee .logs_central_init
```

### Networking Setup
You will have to connect to your deployment machines (we will call them `deploys` for convention). You have many options to do so, but here are a few one-shot ways for convenience. Note that however you choose to connect, these links should not be modified by Ansible using deployments. Otherwise, the modifications could disrupt the Ansible deployment.

#### Local Hotspot
You can create a hotspot on your `central`, which your `deploys` will connect to. We will use DHCP to dynamically assign IP addresses to your `deploys`. Be wary of the network interface you use to create the hotspot: Some dongles have bad Linux compatibility, so YMMV.

```
# Configure the hotspot
LAN_IFACE             # Internet where hotspot will be broadcast
LAN_SSID              # Hotspot SSID
LAN_PASSPHRASE        # Hotspot Password
INTERNET_IFACE=eth0   # (optional) Link with internet, if you want to share

# Important to run sudo with -E, so your above settings are used
LAN_IFACE=wlan0 LAN_SSID=central_hotspot LAN_PASSPHRASE=password INTERNET_IFACE=eth0 sudo -E bash setup/central_hotspot_setup.bash
```
Your devices can now connect to the hotspot. The default settings connect up to 20 devices.

More hotspot configuration options available, have a look at the hostapd/dnsmasq configuration files or the [hotspot setup script](setup/central_hotspot_setup.bash)

#### LAN
You can connect your `central` with your `deploys` over a wired LAN. If you have a router, IP address configurations should already be done for you. Otherwise, you will need to set up a DHCP server on your `central` to assign the IP addresses. Alternatively, all devices can be set up with static IP addresses.

Assuming you have to set up a DHCP server:

```
# Configure the hotspot
# LAN_IFACE                # Interface from central to deploy cluster
# INTERNET_IFACE           # (optional) Link with internet, if you want to share

# Important to run sudo with -E, so your above settings are used
LAN_IFACE=eth0 INTERNET_IFACE=eth1 sudo -E bash setup/central_lan_setup.bash
```

Your devices should get IP addresses on this LAN. The default settings connect up to 20 devices.

More LAN configuration options available, have a look at the dnsmasq configuration files or the [lan setup script](setup/central_lan_setup.bash)

#### Networking Mapping
You can now make a map of your network, in order to identify which devices correspond to which IP address. If you used static ip addressing, you will already know this. Otherwise, you can use the following helper methods, assuming you have exported the environmental variables as used above:

```
sudo apt install arp-scan -y
sudo arp-scan --interface=$LAN_IFACE --localnet

# Get only the ip addresses
sudo arp-scan --interface=$LAN_IFACE --localnet| awk '{print $1}'|tail -n +3|head -n -2
```

### Deploy Setup
Ensure that your `deploys` can be ssh-ed into, so on each `deploy`: `sudo apt install openssh-server`.

#### SSH Keys
You will ideally have SSH access to your `deploys` using passwordless (public-private keys) access. We will assume this for all examples in this repo. To enable passwordless access for all your devices, run this from your `central` for each `deploy`:

```
ssh-copy-id [user]@[ip-address/hostname]
```

### Cloud Setup
If you want to use cloud examples and demos, you will need to set up some credentials. For the example environment using Terraform, you will need to set up your AWS credentials ( After you install the AWS CLI )

```
aws configure
```
[More information for AWS](https://docs.aws.amazon.com/cli/latest/reference/configure/)

## Toolbox Structure
The toolbox consists of the following sections:
* [envs](envs): Tools to set up environments are provided, such as a Docker cluster meant to simulate a physical setup as described in the above README, as well as terraform templates for a cloud instance.
* [roles](roles): Ansible roles which are assigned to various devices. Each role has a folder "example" with a minimal example demonstration tested using a provided [env](envs).
* [demos](demos): A collection of examples of how to "layer" various roles on different devices.

Each role is customized using configuration files, which follow the following convention (using the wg_server role as an example):
* All hosts and their ip addresses are described in an [inventory file](roles/wireguard/wg_server/example/inventory)
* Each role has a corresponding group named for it. In this case, it is "wg_server".
* Variables that are reasonably expected to be common across all devices, and would not likely not cause issues invisibly if the user is not aware of them, are put in the [defaults](roles/wireguard/wg_server/defaults) folder.
* Variables that should be common across all devices, but the user should be aware of them, are put in the [group_vars](roles/wireguard/wg_server/example/group_vars) folder.
* Variables that are host specific, and the user should be aware of, are put in the [host_vars](roles/wireguard/wg_server/example/host_vars) folder.
* The assignment of roles to hosts is found in the [playbook.yml](roles/wireguard/wg_server/example/playbook.yml).
* Each example has a [run](roles/wireguard/wg_server/example/run) file which is provided to run it.
