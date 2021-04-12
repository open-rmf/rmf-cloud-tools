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


