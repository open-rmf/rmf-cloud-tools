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
In some cases, your system might not be configured to be able to establish connections to the main network you are using for RMF. The system might only be accessible over its own hotspot or ethernet interface, for example. In such a scenario, we would require a: "bridge", which connects on one hand to your RMF network, and connects on the other hand to your system. 

From the perspective of the RMF network, communicating with the bridge is equivalent to communicating with the underlying system. The bridge device does this by transparently forwarding all traffic to all ports to the bridge device, down to the underlying system.

### Role: hotspot
In some cases, you might not want to connect your system directly to an RMF network. There might be value to attaching an intermediate abstraction layer between robots and the RMF network. One reason could be that the abstracted system can be more portable between RMF networks: you simply have to change the configurations on the intermediate layer, which you control, rather than going into the details of the underlying systems. 
In such cases, we can set up a hotspot, which your system(s) can connect to over WiFi. 

### Role: Wireguard Server
A VPN can offer a good solution to abstract away to complexity of networking configurations on your underlying systems. This is especially useful on cloud deployments, or when you have no control over the underlying networking infrastructure. We use Wireguard for simplicity, but other VPNs should be similarly capable.

A Wireguard server is the broker for Wireguard clients to send their (encrypted) data. The Wireguard server then forwards the packets. This simple setup has inherent limitations, for example the Wireguard server becomes a single point of failure. It is possible to add infrastructure to improve on this setup. 

In the [architectural diagram](/docs/architecture.ong) we follow, the Wireguard Server would be hosted on the "main" computational module that runs the RMF backend, but this can be modified as necessary.

### Role: Wireguard Client
Complementary to the Wireguard Server is the client. In the [architecture diagram](/docs/architecture.png) we follow, the Wireguard clients exist on the bridge and hotspot modules, which your underlying systems connect to. In this way, we do not have to keep configuring the underlying systems themselves, but only the bridges + hotspot abstraction layer. This is especially useful when the underlying systems might be costly / time consuming to modify.

### Role: Chrony Server
Time synchronization is important since if your reported timestamps are wrong, your robots can behave strangely. Usually, synchronizing time over the Internet is sufficient. However, in scenarios where there might not be access to the Internet, it might be worth setting up a time server in order to synchronize time. [Chrony](https://chrony.tuxfamily.org/) is suitable for this role. A time server is the reference which Chrony clients synchronize time to.

### Role: Chrony Client
Complementary to the Chrony Server is the client, which obtains time from the server for use in timestamps in ROS2 messages.
