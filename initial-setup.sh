#!/bin/bash

ansible-playbook setupcontrol.yaml -v
ansible-playbook setupreposerver.yaml -v
ansible-playbook setuprepoclient.yaml -v
ansible-playbook setupnodes.yaml -v
ansible-playbook timesync.yaml -v

