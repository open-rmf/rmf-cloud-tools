# wg_server
Create a wireguard server on target device(s). Tested using the `docker_cluster` image.

## Setup
Be sure to have done the Setup steps as documented in `env/docker_cluster/README`.
Set up a simulated `docker_cluster` environment with 5 nodes:
```
 LAN_NODE_COUNT=5 bash envs/docker_cluster/run
```

You should now be able to run the runfile:
```
bash roles/wireguard/wg_server/example/run
```

## Results ( Under default configurations )
A folder `wireguard_ws` should be created on your `central` home folder with generated wireguard configurations.

The `server_0` device should have a working wireguard server configuration. To be able to test this setup more fully, we should now add clients. You can find this in the `roles/wireguard/wg_client` folder.

## Further customization
You can further customize the configuration by changing variable assignments in the setup configuration files. This [link](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#group-variables) might help with understanding the configuration file structure in Ansible.

