# ros2 

Install ROS2 on the target device(s). Tested on a localhost device with a user `ubuntu` and ROS2 Foxy.

## Setup
You should be able to run the runfile:
```
bash roles/bootstraps/ros2/example/run
```

## Results ( Under default configurations )
You should have a ROS2 configured with CycloneDDS.

## Further customization
You can further customize the configuration by changing variable assignments in the setup configuration files. This [link](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#group-variables) might help with understanding the configuration file structure in Ansible.

You can find information about the conventions used for configuration files in the [ansible primer](/docs/ansible_primer.md#Conventions).
