# basic_setup

This basic setup demonstrates a minimal setup of the proposed architecture. It consists of a single "main" computer ( localhost, also the same host running Ansible ), running RMF instance on ROS2 CycloneDDS, Wireguard, and an NTP server. You can modify configuration files to add Gateways, which we will describe in "further steps" in the rest of this README.

## Setup
You will need a single computer running Unbuntu 20.04. 

First, modify the inventory so that we have the server's external ip address ( the IP address that the wireguard clients will contact it ):
```
#inventory.yml
[hosts]
controller   ansible_user=ubuntu   ansible_host=127.0.0.1       ansible_connection=ssh  
localhost    ansible_user=ubuntu   ansible_host=127.0.0.1       ansible_connection=ssh  
server_0     ansible_user=ubuntu   ansible_host=[your-server-ip]   ansible_connection=ssh  
```

Make sure you have passwordless access to all devices from your Ansible controller ( the device you will provision on ):
```
ssh-copy-id [all your device ips]
```

And add all necessary private keys to your toolchain, if necessary:
```
ssh-agent bash
ssh-add [all your private keys]
```

If your `ansible_user` does not have passwordless sudo ( meaning you cannot [run sudo without typing your password](https://askubuntu.com/questions/147241/execute-sudo-without-password) ) then you might want to add a new variable at the end of each host entry so that `sudo` commands can be automated:
```
controller   ansible_user=ubuntu   ansible_host=127.0.0.1       ansible_connection=ssh  ansible_sudo_pass=[your-sudo-pass-for-host-'controller']
```
Of course, you should keep this config file secret. You can also think of more complex mechanisms to keep the password from being stored in plain text.


Finally, from the directory root, run 
```
bash demos/basic_setup/run
```

## Cloud Setup
You might want to provision a cloud instance, instead of using a local computer. We should then first create a cloud instance: You can refer [here](/docs/provisioning.md#Cloud-Devices) for instructions to do this. Then, use your cloud server ip in place of `your-server-ip`.

## Adding a Gateway
You can do the following steps to add a new device to your setup. Assuming you have a new device `gPiBridge1.local` that you would like to add:


First, you can add a new host in the `inventory` file:
```
# inventory.yml
[hosts]
controller   ansible_user=ubuntu   ansible_host=127.0.0.1   ansible_connection=ssh  
localhost    ansible_user=ubuntu   ansible_host=127.0.0.1   ansible_connection=ssh  
server_0     ansible_user=ubuntu   ansible_host=192.168.29.10   ansible_connection=ssh  

bridge_0     ansible_user=ubuntu   ansible_host=gPiBridge1.local  ansible_connection=ssh        # ADDED THIS
...

```

Make sure you have ssh passwordless access to the device:
```
ssh-copy-id ubuntu@gPiBridge1.local
```

You can assign role(s) for this new device. In this case we will turn the device into a Gateway, which as the roles `ros2`, `wg_client`, and `bridge`:

```
# inventory.yml
---

[ros2]
localhost
bridge_0                                        # ADDED THIS

[rmf_demos_vcs]
localhost  

[wg_server]
server_0

[unicast_cyclonedds_peers]
server_0
bridge_0                                        # ADDED THIS

[bridge]                                        # ADDED THIS
bridge_0

[wg_client]                                     # ADDED THIS
bridge_0  
```

Add a new `host_vars` for the `bridge_0` device called `bridge_0.yml`, with configurations copied and modified from the various role examples:
```
# host_vars/bridge_0.yml
# Role: ROS2
---
ros2_gpg_key_url: https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc            
ros2_repository_url: http://packages.ros.org/ros2/ubuntu
ros2_distribution: foxy
ros2_rmw_implementation: rmw_cyclonedds_cpp          
ros2_domain_id: 99
ros2_installation_type: ros-base
ros2_cycloneddsxml_path: "/etc"
ros2_dds_network_interface: wg0           

# unicast_cyclonedds
unicast_cyclonedds_max_auto_participant_index: 50             
unicast_cyclonedds_dds_network_interface: wg0             
unicast_cyclonedds_dds_ip: 10.0.0.2
unicast_cyclonedds_cycloneddsxml_path: "/etc"
unicast_cyclonedds_group_name: "unicast_cyclonedds_peers"

# wg_client
wg_client_wireguard_workspace_path: "/home/ubuntu/wireguard_ws"          
wg_client_wireguard_subnet: 24                                            
wg_client_wireguard_network_port: 51820
wg_client_wireguard_network_interface: wg0
wg_client_external_dns: 8.8.8.8
wg_client_wireguard_path: "/etc/wireguard"                               
wg_client_client_wireguard_ip: 10.0.0.2
wg_client_server_name: localhost
wg_client_server_wireguard_ip: 10.0.0.1                
wg_client_wireguard_allowed_ips: 10.0.0.0/24           
wg_client_has_systemctl: true

# bridge
bridge_device_network_interface: eth0              
bridge_upstream_network_interface: wlan0          
bridge_device_ip: 10.42.0.1                
bridge_dns: 8.8.8.8   

```

If necessary, modify the `playbook.yml` file ( if you added new roles ):
```
# playbook.yml

- hosts: ros2
  roles:
    - ros2

- hosts: rmf_demos_vcs
  roles:
    - vcs

- hosts: bridge
  roles:
    - bridge

- hosts: wg_server
  roles:
    - wg_server

- hosts: wg_client
  roles:
    - wg_client

- hosts: unicast_cyclonedds_peers
  roles:
    - unicast_cyclonedds
```


We can now run our playbook once again:
```
bash demos/basic_setup/run
```
