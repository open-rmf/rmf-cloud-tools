# rmf-cloud-tools

Tools and tutorials to aid in RMF deployment and testing efforts.

## Motivation

RMF deployments can be reasonably complex, due to its multi-disciplinary nature. We hope the tools and tutorials found here can be leveraged to simplify the deployment experience. This repository distills a collection of shortcuts, tools and automation to help understand RMF and make it work for you. 

To start the walk through, we can look at:
* A high level [architectural description](docs/architecture.md)
* A brief [primer](docs/ansible_primer.md) on Red Hat Ansible, our automation tool, and the conventions used in this repository.
* Various [provisioning tools](docs/provisioning.md) that can be used to set up testing containers , cloud machines or connect to physical infrastructure.

Once you are familiar, head over to have a look the various [ansible roles](./roles) and have a look at how they are used to set up the proposed [architecture](docs/architecture.md).

## General Structure

The repository revolves around useful infrastructure that are commonly found across RMF deployments. We aim to address common pain points when doing real deployments which are often multi-disciplinary in nature, such as:

* How do we best manage possible IP address conflicts when multiple systems, developed by different owners with different conventions, have to operate on the same network?
* How do we best synchronize time so that RMF can coordinate systems accurately?
* Some systems can only be controlled by connecting to its access point, so it cannot connect to the main deployment network. How can I integrate this robot?
* How do we best test a system for scaling and inter-operability, without physically assembling the entire physical setup?

### Automation
Where we can, we try to automate the set up steps using [Red Hat Ansible](https://www.ansible.com/). We have tried to design it to be as flexible as possible, which hopefully facilitates easier deployment management through [infrastructure as code](https://en.wikipedia.org/wiki/Infrastructure_as_code). 

However, it is not always possible to automate, and often automation becomes inflexible and limiting. 

### Tutorials
Due to limitations of automation and the need to customize infrastructure to your specific use case, tutorials and explainations accompany the automation scripts. This hopefully is illuminating and helps you to modify the infrastructure for your unique setup.

## Feedback
We are always looking for ways to improve. Do place an issue whenever you find a bug or think of better solutions, so we can improve this document together.

## Glossary
[Here](/Glossary.md) we compile a list of terms which might need explanation for those new to ROS2 / RMF / this repository. Do suggest adding more terms here where useful.
