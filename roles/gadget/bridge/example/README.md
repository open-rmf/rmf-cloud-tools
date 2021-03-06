# bridge
Create a "pi bridge" on target device. This bridge connects to a target device over a `device_network_interface`. You can connect to the RMF network on another `upstream_network_interface.` Then, it bridges the two interfaces such that you can interact with the pi bridge over the RMF network as if it was the downstream device. A Tested on a Raspberry Pi running Ubuntu Desktop 21.04.

## Setup
* Flash a Raspberry Pi 4 with [Ubuntu Desktop 21.04](https://ubuntu.com/download/raspberry-pi). You can also flash the Server edition, but you will need to be familiar of operating without GUI.
* Make sure that the device runs an ssh server: `sudo apt install openssh-server`.
* Connect your Rpi your `controller` over a network interface thats not configured as its `device_network_interface` as specified in its `host_vars` file. You can see the many ways to connect, as described in the [provisioning](/docs/provisioning.md) steps.
* `ssh-copy-id [pi-user]@[pi-address]`  and try `ssh` to test your connection to make sure you have sudo access
* Configure `inventory` file with the details of your new device. Also configure the `bridge_device_ip` with the ip address of the target device with respect to the pi bridge. In other words, the ip address you would use to ping the target device from the pi.
* Try to make sure any automatic upgrades are already complete. You should be able to run `sudo apt update` on the Rpi without `apt-lock` errors.


You should now be able to run the runfile:
```
bash roles/gadget/bridge/example/run
```

* Finally, you can use NetworkManager, or any networking tool of your choice, to connect the bridge to your RMF network. 


## Results ( Under default configurations )
You should be able to access the target device from the RMF network by interacting directly with the pi. For example, if your target has an ip address of `10.42.0.1` with respect to the bridge, and has a SimpleHttpServer running on port 8000:
```
python3 -m http.server
```
And the pi bridge ip address on the wireless network is `192.168.29.10`, then you can access the server on the target device by using 
```
curl 192.1.68.29.10:8000
```

## Further customization
You can further customize the configuration by changing variable assignments in the setup configuration files. This [link](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#group-variables) might help with understanding the configuration file structure in Ansible.

You can find information about the conventions used for configuration files in the [ansible primer](/docs/ansible_primer.md#Conventions).
