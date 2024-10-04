#!/bin/bash

ansible-playbook playbooks/setupcontrol.yaml -v
ansible-playbook playbooks/setupreposerver.yaml -v
ansible-playbook playbooks/setuprepoclient.yaml -v
ansible-playbook playbooks/setupnodes.yaml -v
ansible-playbook playbooks/timesync.yaml -v

