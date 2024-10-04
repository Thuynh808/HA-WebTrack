# HA-WEBTRACK Project

## Overview
The HA-WEBTRACK project is designed to create a high-availability web server environment using a variety of open-source tools. This infrastructure includes load balancing with HAProxy, web serving with Apache HTTPD, and comprehensive monitoring and logging with Prometheus, Grafana, Loki, and Alertmanager. The entire deployment and configuration are automated using Ansible.

## Getting Started

### Prerequisites
Before you begin, ensure you have the following prepared:
- **Git** and **Ansible** installed on your control machine.
- **Four RHEL 9 VMs**: These will act as your control node, load balancer, and two web servers.
- **Network Configuration**: Set IP addresses and hostnames for each VM using `nmtui` to ensure proper networking.
- **Ansible User**:
  - Create an `ansible` user on all VMs for Ansible to use for automation tasks.
  - Set up an SSH key pair for the `ansible` user with:
    
    ```bash
    ssh-keygen
    ```
  - Add the `ansible` user to the `sudoers` file to grant necessary privileges:
    
    ```bash
    echo 'ansible ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/ansible
    ```

### Installation
To install and set up the project, follow these steps:

1. **Clone the repository:**
   
    ```bash
    git clone https://github.com/Thuynh808/HA-WebTrack
    cd HA-WebTrack
    ```
3. **Install required Ansible collections:**
   
   ```bash
   ansible-galaxy collection install -r requirements.yaml
   ```
4. **Mount the rhel iso:**

   ```bash
   sudo mount /dev/sr0 /mnt
   ```
5. **Run the initial setup script:**
   
   ```bash
   ./initial-setup.sh
   ```
   This script prepares our ansible environment by setting up necessary ansible user, hosts configurations and prerequisites.
6. **Execute the main Ansible playbook:**

   ```bash
   ansible-playbook site.yaml -vv
   ```
   This command starts the configuration of all components as defined in the playbook. The -vv option increases verbosity, which can help with troubleshooting if needed.

### Verification
After installation, verify that all components are running correctly by accessing the following URLs and ensuring that each service is operational:

Control Node Services:

Grafana: http://192.168.68.90:3000
Prometheus: http://192.168.68.90:9090
Loki: http://192.168.68.90:3100
Alertmanager: http://192.168.68.90:9093
Load Balancer and Monitoring Tools:

HAProxy (Load Balancer): `http://192.168.68.91:80`
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
