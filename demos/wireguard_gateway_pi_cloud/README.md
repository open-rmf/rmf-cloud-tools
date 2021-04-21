# wireguard_gateway_pi_cloud

This will set up a 3 device demo of the [Robotics Middelware Framework](http://github.com/open-rmf/) over wireguard VPN. It consists of:

1. Terraform Wireguard server node in the cloud
2. A Raspberry Pi 4 acting as a Gateway to the Wireguard VPN
3. Your localhost as a `central` that controls the ansible deployment, but also participates in the demo by running RMF

## Setup

First, we should set up a terraform cloud instance. We can use the default setup:
```
bash envs/terraform_node/auth/generate
bash envs/terraform_node/run
export CLOUD_SERVER_IP=[YOUR-CLOUD-SERVER-IP]
```

Next connect our Raspberry Pi 4 over ethernet LAN and get its IP address:
```
LAN_IFACE=[YOUR-ETHERNET-IFACE] INTERNET_IFACE=[YOUR-INTERNET-IFACE] sudo -E bash setup/central_lan_setup.bash
sudo arp-scan --interface=[YOUR-ETHERNET-IFACE] --localnet
export RPI_GATEWAY_IP=[YOUR-RPI-IP]
```

We should now be able to ssh into the two devices
```
ssh ubuntu@$CLOUD_SERVER_IP
ssh ubuntu@RPI_GATEWAY_IP
```

Check for internet access as well:
```
ping www.[your-preferred-website].com
```

Run the playbook!
```
bash demos/wireguard_gateway_pi_cloud/run
```

Now try running talkers from any device and verify that the other devices receive it.
```
ros2 topic pub /chatter std_msgs/String ""
ros2 topic list
```

You can try running the office demo from `central` and see that other devices can publish and subscribe to it:
```
ros2 launch rmf_demos office.launch.xml
```

## Modifying this example
Here are some things you can do to modify this example to suit your setup.

### Change your server_0 host ip address
Modify the [inventory](./inventory) line 2, ansible_host to your devices ip address.

### Assign more hotspots
Modify the [inventory](./inventory) by adding a new host under [hosts]. For example

```
hotspot_2 ansible_user=ubuntu ansible_host=192.168.29.20  ansible_connection=ssh
```

Add the device name ( in this case `hotspot_2` ) to the corresponding roles. For example: [wg_client], [ros2], [peers].

Add a new file `hotspot_2.yaml` in the `host_vars` folder, modifying as appropriate from `hotspot_1.yaml`. For example:
```
---
# hotspot
hotspot_ssid: hotspot_2
hotspot_psk: password
external_network_interface: eth0
hotspot_network_interface: wlan0

# peers 
dds_ip: 10.0.0.4
cycloneddsxml_path: "/home/ubuntu"
dds_network_interface: wg0

# ros2
ros2_installation_type: ros-base
dds_network_interface: wg0

# wg_client
client_wireguard_ip: 10.0.0.4
has_systemctl: true
```
