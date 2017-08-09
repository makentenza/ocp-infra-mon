# OCP Infrastructure and Internals Monitoring (In Progress)

The aim of this repository is to automate the deployment for an Infra and Internals Monitoring solution for OpenShift Container Platform. This solution is based in the OpenSource project [Icinga 2.](https://www.icinga.com/products/icinga-2/)

The whole solution is deployed as containers in OCP. In order to remove the solution there are only 2 actions required:

1. Delete the 'infra-monitor' namespace created by the automated deployment
2. Optionally remove '/var/inframon-agent' directory and the iptables rule for port TCP/5666 from every Node

## Pre-deployment requirements

1. Two persistent volumes (1Gi and 5Gi) must be available to be consumed by inframon-host deployment
2. An user with cluster-admin privileges must be logged to OCP API from first Master
3. Modify [DaemonSet](templates/inframon-agent.yaml#L55) configuration to match your internal registry IP address/name
4. Modify [Agent Config](image/agent/include/nrpe_conf/nrpe.cfg#L6) to include the SubNet where OCP Nodes have the primary IP condifured

## Deployment Instructions

- Clone existing repository (fork it to your own GitHub so you can make changes)

  ``` git clone https://github.com/makentenza/ocp-infra-mon.git ```

- Use the exiting playbook with your OCP inventory

  ``` ansible-playbook -i {ocp_inventory_file} ocp-infra-mon/ansible/main.yml ```

## Post-deployment Instructions

The Ansible playbook will prepare your environment and create different objects. Two builds will be triggered as well to build the container images for both the Host and the Agent.

Once the builds are completed, the Inframon Host will be automatically deployed and the associated service will be exposed. Use the following credentials to access to the Web Console:

    User: icingaadmin
    Password: icinga

The agents will be deployed as DaemonSets using the selector 'inframon-agent=true' to place the Pods on every Node. Label your Nodes properly so they could be placed:

  ``` oc label node --all inframon-agent=true ```
