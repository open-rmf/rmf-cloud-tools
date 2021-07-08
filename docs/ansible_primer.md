# Ansile Primer

Ansible is a useful automation tool for setting up infrastructure. We use it because it requires no setup on the target devices ( apart from SSH key access ) and is written in YAML, which helps readability. We use Ansible to automate the setting up of various Ansible Roles to accomplish infrastructure setup objectives. 

You can think of Ansible Roles as certain capabilities of an infrastructure device, which can be layered over each other. For example, the [Gateway](/docs/architecture.md#Gateway) has a combination of a few ansible Roles:

* hotspot / bridge
* wireguard client
* ros2

Using Ansible should hopefully allow you to scale up your deployments more quickly and repeatably, keep infrastructure up to date and document your infrastructure configuration as readable and accessible code.

Some Ansible concepts can be found [here](https://docs.ansible.com/ansible/latest/network/getting_started/basic_concepts.html). Hopefully, you should be able to use these examples with some basic understanding.

## Conventions
The roles can be found in the [roles folder](/roles). Each role follows a similar structure:

```
[role-name]
  - example
    - host_vars
    - inventory
    - playbook.yml
  - tasks
  templates
  README.md
  run
```
A `host` is a device which will be provisioned with one or more ansible roles.

The `example` folder contains a simple example on how the automation is used. The `example` folder contains a few standard files:
* `host_vars`: A folder containing host specific configuration variables
* `inventory`: A file which contains all the hosts that will be participating in this playbook. It contains a list of alias names mapping to the specific ip address and usernames of the device, and then a list of assignments of roles to hosts. For example:
```
[hosts]
localhost ansible_user=ubuntu ansible_host=127.0.0.1  ansible_connection=ssh

[ros2]
localhost
```
Describes an alias `localhost` which we will access with user `ubuntu` at ip address `127.0.0.1` over ssh. This `localhost` is then assigned the group `ros2`.
* `playbook.yml`: A list of role assignments is formally made in this file.
* `README.md`: Documentation for this specific example.
* `run`: A helper script which automates the commands necessary to run this example. By following the `README.md`, you should be able to simply use the `run` file to set up your infrastructure.

The `tasks` folder contains `yaml` specifications on how to carry out role provisioning.

The `templates` folder contains jinja templates that are used by Ansible to carry out this role provisioning.

## Modifying examples
Here are some common actions you would do to modify an ansible role for your deployment.

### Add your own device
You would first modify the `inventory` file to add your device, and then assign that role to it. Using the previous example:
```
[hosts]
localhost ansible_user=ubuntu ansible_host=127.0.0.1  ansible_connection=ssh
your_device ansible_user=your_user  ansible_host=your_ip_address  ansible_connection=ssh

[ros2]
localhost
your_device
```

You would then duplicate the `localhost.yml` configuration file in the `host_vars` folder and configure it to your specific device.

### Assign multiple roles
You can add multiple roles to the same device. For example:
```
[hosts]
localhost ansible_user=ubuntu ansible_host=127.0.0.1  ansible_connection=ssh

[ros2]
localhost

[hotspot]
localhost
```
and editing the `playbook.yml`:
```
---
- hosts: ros2
  roles:
    - ros2
- hosts: hotspot
  roles:
    - hotspot
```
Would assign the `hotspot` and `ros2` ansible roles.
