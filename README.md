# rmf-cloud-tools
Deployment tools for using RMF in clouds


!!! :warning: Warning/Achtung this is extremely unstable at the moment !!!


Whatever I've written in the readme semi-works but currently has security loopholes!!

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
ping 10.200.200.0
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
To clean up the mess thats been created we can 
## Setting up clients
For each client in the client folder we have a wireguard key and 


## Scaling up
Use chef. [TODO explain how]

## TODO
* Stop passing `wg0.conf` in `user_data`. This is very bad practice. 
* Custom ssh key to log in.
* Make region configureable.
* Make clients configureable.
* Make IP namespace configureable.
* Generate G-Pi images