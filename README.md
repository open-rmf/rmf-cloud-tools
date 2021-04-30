# rmf-cloud-tools
# PLEASE REFER TO THE "ansible_revamp_improved_documentation" branch while its being reviewed!
# https://github.com/open-rmf/rmf-cloud-tools/tree/ansible_revamp_improved_documentation
Deployment tools for using RMF in clouds


!!! :warning: Warning/Achtung this is extremely unstable at the moment !!!


# Current Status
This shows a proof-of-concept deployment of ROS2 Foxy in the cloud 
via FastRTPS middleware.

# Usage
You will need to have [terraform](https://www.terraform.io/) and 
[aws cli](https://aws.amazon.com/cli/) installed. You will also need
to have wireguard-tools installed. on ubuntu this is as simple as:
```shell
sudo apt install wireguard-tools
```

To provision a server simply run the following commands:
```shell
ruby generate_configs.rb 1 # 1 refers to the number of clients.
```

This will create a folder called `scripts` and another folder called `clients`.
The scripts folder contains all the information required to provision a VM via
`cloud-init`. While the `clients` folder contains everything needed for the
clients (more on that later).

## Testing VPN on the client
To test the VPN simply provision a client vm. In particular we will spawn a client
VM. You will need [vagrant](https://www.vagrantup.com/) to do this.
This is as simple as the following:
```
cd clients/client_1
vagrant up
vagrant ssh
```
This will drop you into a client shell. To test the connection to the server
one can simply run the following:
```
sudo wg0
```
We can try to ping the server
```
ping 10.200.200.1
```
Once done testing your client out exit and clean up your clientvm:
```
vagrant destroy
```
You may also clean up the cloud instances by running.
```
cd terraform/
terraform destroy
```
## Setting up ROS2 connection (via FASTRTPS)

Wireguard does not allow for multi-cast, hence we need to have a special configuration
for Fast-RTPS. The config file is generated once the IPs have been allocated by
Terraform. To inspect the config you may ssh into the server and enter:

```
cat $FASTRTPS_DEFAULT_PROFILES_FILE
```

Its trivial to set up a ROS 2 based connection over the network. On the server one can
simply run:
```
ros2 topic pub /talker  std_msgs/String "data: Hello"
```
On the client VM one can run the usual:
```
ros2 topic echo /talker
```
## Scaling up
Use chef. [TODO explain how]

## TODO
* Make region configureable.
* Make clients configureable.
* Make IP namespace configureable.
* Generate G-Pi images
* Bridge network
