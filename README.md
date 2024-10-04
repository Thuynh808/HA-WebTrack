# HA-WebTrack

Getting Started
Prerequisites
Before you begin, ensure you have the following prepared:

Git and Ansible installed on your control machine.
Four RHEL 9 VMs: These will act as your control node, load balancer, and two web servers.
Network Configuration: Set IP addresses and hostnames for each VM using nmtui to ensure proper networking.
Ansible User:
Create an ansible user on all VMs for Ansible to use for automation tasks.
Set up an SSH key pair for the ansible user and copy the public key to all target VMs for passwordless SSH access.
Add the ansible user to the sudoers file to grant necessary privileges:
```bash
echo 'ansible ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/ansible
```
This command gives the ansible user passwordless sudo access, which is typically required for running Ansible playbooks.
Appropriate access to manage devices (root or sudo privileges).
Installation
To install and set up the project, follow these steps:

Clone the repository:

```bash
git clone https://github.com/Thuynh808/HA-WebTrack
cd HA-WebTrack
```
Install required Ansible collections:

```bash
ansible-galaxy collection install -r requirements.yaml
```
Mount the installation media (if applicable):

```bash
sudo mount /dev/sr0 /mnt
```
This step is necessary for accessing any resources that might be on a CD/DVD or similar media. Adjust the device and mount point as necessary based on your environment.

Run the initial setup script:

```bash
./initial-setup.sh
```
This script prepares your environment by setting up necessary configurations and prerequisites.

Execute the main Ansible playbook:

```bash
ansible-playbook site.yaml -vv
```
This command starts the configuration of all components as defined in the playbook. The -vv option increases verbosity, which can help with troubleshooting if needed.

Verification
After installation, verify that all components are running correctly by accessing the following URLs and ensuring that each service is operational:

Control Node Services:

Grafana: http://192.168.68.90:3000
Prometheus: http://192.168.68.90:9090
Loki: http://192.168.68.90:3100
Alertmanager: http://192.168.68.90:9093
Load Balancer and Monitoring Tools:

HAProxy (Load Balancer): http://192.168.68.91:80
Node Exporter: http://192.168.68.91:9100
HAProxy Exports: http://192.168.68.91:8405/metrics
Promtail: http://192.168.68.91:9080
Web Servers:

Web Server 1 (node2.streetrack.org): http://192.168.68.92:80

Node Exporter: http://192.168.68.92:9100

Promtail: http://192.168.68.92:9080

Web Server 2 (node3.streetrack.org): http://192.168.68.93:80

Node Exporter: http://192.168.68.93:9100

Promtail: http://192.168.68.93:9080

Troubleshooting
If you encounter issues during the Ansible playbook execution, check the Ansible logs for detailed error messages.
Ensure all prerequisites are correctly installed and configured before starting the installation.
For issues related to specific components, refer to the component's documentation or the troubleshooting section of this guide.
