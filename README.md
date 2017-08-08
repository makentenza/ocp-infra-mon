# OCP Infrastructure Monitoring (In Progress)

The aim of this repository is to automate the deployment for a Infra and Internals Monitoring solution for OpenShift Container Platform. This solution is based in the OpenSource product Icinga 2 [https://www.icinga.com/products/icinga-2/].

## Pre-deployment requirements

1. Two persistent volumes (1Gi and 5Gi) must be available to be consumed by inframon-host deployment
2. A user with cluster-admin privileges must be logged to OCP API from first Master
  
## Deployment Instructions

- Clone existing repository

  ``` git clone https://github.com/makentenza/ocp-infra-mon.git ```

- Use the exiting playbook with your OCP inventory

  ``` ansible-playbook -i {ocp_inventory_file} ocp-infra-mon/ansible/main.yml ```
