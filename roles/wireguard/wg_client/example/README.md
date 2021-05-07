# wg_client
Create a wireguard client on target device(s). Tested using the `docker_cluster` environment.

## Setup
You will first need to set up a wireguard server. If following the examples in this repo using `docker_cluster`, you should follow the instructions in `roles/wireguard/wg_server/example`.

You should have **already** set up a simulated `docker_cluster` environment with 5 nodes:
```
 LAN_NODE_COUNT=5 bash envs/docker_cluster/run
```

You should now be able to run the runfile:
```
bash roles/wireguard/wg_client/example/run
```

## Results ( Under default configurations )
A folder `wireguard_ws` should be created on your `controller` home folder with generated wireguard configurations.

The devices in the `wg_client` group should have a working wireguard client configuration. The device specified as `server_name` should now also have its wireguard configuration correctly configured to add this client. From the device called `server_name`, you should be able to ping every device in the `client_group` by their wireguard ip.


## Further customization
You can further customize the configuration by changing variable assignments in the setup configuration files. This [link](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#group-variables) might help with understanding the configuration file structure in Ansible.

You can find information about the conventions used for configuration files in the [ansible primer](/docs/ansible_primer.md#Conventions).

