# roles

The Ansible roles provided here provide reusable infrastructure that meet various common use-cases in a deployment scenario. Each role is accompanied, in its README, a list of concepts and (mostly command line) instructions on how to reproduce the ansible roles manually. This should help with understanding what the role does, as well as how to modify it to fit your specific scenarios.

Some "roles" may be too general, trivial or difficult to automate. In those cases, the README will function more as a tutorial on how to set up from scratch, and links to various resources to find out more.

## Use Cases
In this section, we will describe common use cases based on the [general architecture diagram](/docs/architecture.md)
![architecture-diagram](/docs/architecture.png)

We do assume working knowledge of ROS2, but do refer to the Glossary for quick primers and links on technical terms you might find.

### Role: ros2
Machines that operate on RMF will need to communicate over ROS2. This role will bootstrap a target machine with ROS2 binaries, similiar to how an installation will happen by following the [ROS2 installation docs](https://docs.ros.org/en/foxy/Installation/Ubuntu-Install-Binary.html).

### Role: vcs
[vcstool](https://github.com/dirk-thomas/vcstool) is a common tool that is used in ROS2 and RMF for workspace version control. This role will automatically generate a ROS2 workspace, install dependencies and build a workspace based on a `.repos` file hosted on the Internet. It assumes you already have a ROS2 role deployed.

### Role: unicast_cyclonedds
In some cases ( such as over a cloud deployment ) there might be a few reasons not to use DDS multicast discovery. DDS discovery might not work well, perhaps due to the nature of your network architecture. ( [This](https://ubuntu.com/blog/exploring-ros-2-with-kubernetes) article gives a good overview of issues with ROS2 discovery ). It could also be more secure to only whitelist certain IP addresses ( perhaps we don't want to allow "any" device to participate ). In these cases, we can configure DDS to only interact with specific IP addresses.

right now, only CycloneDDS has been researched and tested, but we welcome variants on other DDS vendors.

### Role: bridge 
In some cases, your system might not be configured to be able to establish connections to the main network you are using for RMF. The system might only be accessible over its own hotspot or ethernet interface, for example. In such a scenario, we would require an intermediate device, which we call a "bridge", which connects on one hand to your RMF network, and connects on the other hand to your system. 

From the perspective of any device on the RMF network, communicating with the bridge device is equivalent to communicating with the underlying system. The bridge device does this by transparently forwarding all traffic to all ports to the bridge device, down to the underlyging system.

### Role: hotspot
In some cases, you might not want to connect your robot directly to a RMF network. There might be value to attaching an intermediate layer between robots and the RMF network. T
