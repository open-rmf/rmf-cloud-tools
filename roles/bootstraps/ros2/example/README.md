# ros2 

Install ROS2 on the target device(s). Tested on a localhost device with a user `ubuntu` and ROS2 Foxy.

## Setup
You should be able to run the runfile:
```
bash envs/roles/bootstraps/vcs/example/run
```

## Results ( Under default configurations )
You should have ROS2 Foxy, a minimal `cyclonedds.xml` configuration in the `/home/ubuntu`, and configured to use CycloneDDS on a `ROS_DOMAIN_ID` of 0.

## Further customization
You can further customize the configuration by changing variable assignments in the setup configuration files. This [link](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#group-variables) might help with understanding the configuration file structure in Ansible.



