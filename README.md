# rmf-cloud-tools
Deployment tools for using RMF in clouds


!!! Warning/Achtung this is extremely unstable at the moment !!!


Whatever I've written in the readme doesn't yet work it will work in 
< 24h.

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
ruby generate_configs.rb 5 # 5 refers to the number of clients.
```

This will create a folder called `scripts` and another folder called `clients`.
The scripts folder contains all the information required to provision a VM via
`cloud-init`. While the `clients` folder contains everything needed for the
clients (more on that later).

Next run the following:
```
cd terraform
terraform init
terraform apply
```
You will now have an AWS server configured with ros2 and fastrtps that can talk 
to clients.

## Setting up clients
For each client in the client folder


## Scaling up
Use chef. [TODO explain how]