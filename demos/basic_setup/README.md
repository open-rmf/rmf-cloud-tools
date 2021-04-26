# basic_setup

This basic setup demonstrates a minimal setup of the proposed architecture. It consists of a single "main" computer ( localhost, also the same host running Ansible ), running RMF instance on ROS2 CycloneDDS, Wireguard, and an NTP server. You can modify configuration files to add Gateways, which we will describe in "further steps" in the rest of this README.

## Setup
You will need a single computer running Unbuntu 20.04. From the directory root, run
```
bash demos/basic_setup/run
```
