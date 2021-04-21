# hotspot
Create a hotspot on target device(s). Tested on a Raspberry Pi running Ubuntu Server 20.04.

## Setup
* Flash a Raspberry Pi 4 with [Ubuntu Server 20.04](https://ubuntu.com/download/raspberry-pi).
* Connect your Rpi your `central` using wired Ethernet Cable and the LAN Networking Setup as described in the root README.md. Don't use the Hotspot Networking Setup method, as we need the wireless link to set up our hotspot.
* `ssh-copy-id [pi-user]@[pi-address]`  and try `ssh` to test your connection.
* Configure `inventory` file with the details of your new device.
* Try to make sure any automatic upgrades are already complete. You should be able to run `sudo apt update` on the Rpi without `apt-lock` errors.


You should now be able to run the runfile:
```
bash envs/roles/wireguard/wg_client/example/run
```

## Results ( Under default configurations )
Upon completion, With the default configurations, we should expect the RPi to broadcast a hotspot with SSID `hotspot_1` with password `password`. Assuming your `central` link is sharing Internet, any device connecting to the hotspot will also have internet access.

## Further customization
You can further customize the configuration by changing variable assignments in the setup configuration files. This [link](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#group-variables) might help with understanding the configuration file structure in Ansible.

You can find information about the conventions used for configuration files in the [main README](/README.md#toolbox-structure).

