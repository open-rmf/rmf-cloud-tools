# vcs 

Clones and builds a VCS-type ROS2 workspace at the target devices. Tested on a localhost device building [rmf_demos](https://github.com/open-rmf/rmf_demos). 

## Setup
We assume you already have ROS2 installed on your target machine.

You should now be able to run the runfile:
```
bash envs/roles/bootstraps/vcs/example/run
```

## Results ( Under default configurations )
Your target device should have the RMF demos workspace built in `$HOME/ros2_ws`.

## Further customization
You can further customize the configuration by changing variable assignments in the setup configuration files. This [link](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#group-variables) might help with understanding the configuration file structure in Ansible.

You can find information about the conventions used for configuration files in the [ansible primer](/docs/ansible_primer.md#Conventions).

