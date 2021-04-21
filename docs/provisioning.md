# provisioning
Tutorials on provisioning infrastructure.

TODO

## docker_cluster
This environment will provision a given number of Docker containers automatically. This simulates a cluster of devices on a local network. You can use this to test out Ansible playbooks, or do other sorts of debugging.

This setup currently only supports /24 subnets.

### docker_cluster setup
```
# First, we generate authentication keys. From ansible_toolbox root
bash envs/docker_cluster/auth/generate

# If using the provided minimal docker image, build the image
bash envs/docker_cluster/docker/build

# Then, we configure the run script
# LAN_START_IP      # The starting IP address of the cluster. Every node is assigned an ip address relative to this
# LAN_NODE_COUNT    # Number of nodes on this network
# DOCKER_IMAGE      # The image to use. Defaults to the provided Docker: docker_cluster/node.docker"

# Now, we can launch the cluster, and ssh into them
bash envs/docker_cluster/run
ssh root@192.168.29.10

# We can have more than the default number of nodes and the start ip
LAN_NODE_COUNT=5  LAN_START_IP=192.168.29.29 bash envs/docker_cluster/run
ssh root@192.168.29.29

# We can use other images if we want ( This example nodes will terminate immediately because no processes are run )
DOCKER_IMAGE=osrf/ros2:nightly bash envs/docker_cluster/run
```

## terraform_node
This will set up a single node on AWS using Terraform. You will need to set up your AWS credentials on the AWS CLI.This can be used as a cloud server or VPN server.

### terraform_node setup
```
# We will generate authentication keys. From ansible_toolbox_root
bash envs/terraform_node/auth/generate

# Customize the terraform files. Edit the following lines:
grep -i -n "Change" envs/terraform_node/*.tf

# Bringup the node
bash envs/terraform_node/run

# SSH in!
ssh -i envs/terraform_node/auth/terraform_node_id_rsa ubuntu@[your-server-ip]
```

