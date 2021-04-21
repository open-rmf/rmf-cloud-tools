# unicast_cyclonedds

Sometimes, you cannot rely on CycloneDDS default configuration, for example if going through Wireguard. This role will export a variant of CycloneDDS configurations that is compatible with unicast.

## Setup
You should be able to run the runfile:
```
bash roles/bootstraps/unicast_cyclonedds/example/run
```

Note that the variable `max_participant_index` should be large enough so that there is enough participant indices for all the necessary subscribers. See [here](https://github.com/eclipse-cyclonedds/cyclonedds/blob/master/docs/manual/options.md#cycloneddsdomaindiscoverymaxautoparticipantindex) for more information.

## Results ( Under default configurations )
You should find a `cyclonedds.xml` file in the `cycloneddsxml_path` with all the `peers` group devices configured.

## Further customization
You can further customize the configuration by changing variable assignments in the setup configuration files. This [link](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#group-variables) might help with understanding the configuration file structure in Ansible. 

You can find information about the conventions used for configuration files in the [main README](/README.md#toolbox-structure).
