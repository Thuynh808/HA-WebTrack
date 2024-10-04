# HA-WEBTRACK Project

## Overview
The HA-WEBTRACK project is designed to create a high-availability web server environment using a variety of open-source tools. This infrastructure includes load balancing with HAProxy, web serving with Apache HTTPD, and comprehensive monitoring and logging with Prometheus, Grafana, Loki, and Alertmanager. The entire deployment and configuration are automated using Ansible.

## Getting Started

### Prerequisites
Before you begin, ensure you have the following prepared:
- **Git** is installed on your control machine.
- **Four RHEL 9 VMs**: These will act as your control node, load balancer, and two web servers.
- **Network Configuration**: Set IP addresses and hostnames for each VM using `nmtui` to ensure proper networking. Ensure that the networking mode is set to `Bridge Adapter` to allow the VMs to directly communicate with the network as independent devices, which is essential for proper operation of services like HAProxy and the web servers.


    | Host Name                 | IP Address     | Description                   |
    |---------------------------|----------------|-------------------------------|
    | control.streetrack.org    | 192.168.68.90  | Grafana, Prometheus, Loki, Alertmanager |
    | node1.streetrack.org      | 192.168.68.91  | Load balancing the web servers, Node Exporter, HAProxy Exports, Promtail |
    | node2.streetrack.org      | 192.168.68.92  | Apache HTTPD, Node Exporter, Promtail |
    | node3.streetrack.org      | 192.168.68.93  | Apache HTTPD, Node Exporter, Promtail |


- **Ansible User**:
  - Create an `ansible` user on localhost and set password to `password`:<br><br>
  ```bash
  useradd ansible
  passwd ansible
  ```
  - Set up an SSH key pair for the `ansible` user with:<br><br>
  ```bash
  ssh-keygen
  ```
  - Add the `ansible` user to the `sudoers` file to grant necessary privileges:<br><br>
  ```bash
  sudo echo 'ansible ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ansible
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

### Services and URLs

  | Server | Service Name | URL |
  |--------|--------------|-----|
  | Control Node | Grafana | [http://192.168.68.90:3000](http://192.168.68.90:3000) |
  | Control Node | Prometheus | [http://192.168.68.90:9090](http://192.168.68.90:9090) |
  | Control Node | Loki(through Grafana) | [http://192.168.68.90:3000](http://192.168.68.90:3000) |
  | Control Node | Alertmanager | [http://192.168.68.90:9093](http://192.168.68.90:9093) |
  | HAProxy (node1.streetrack.org) | HAProxy | [http://192.168.68.91:80](http://192.168.68.91:80) |
  | HAProxy (node1.streetrack.org) | Node Exporter | [http://192.168.68.91:9100](http://192.168.68.91:9100) |
  | HAProxy (node1.streetrack.org) | HAProxy Exports | [http://192.168.68.91:8405/metrics](http://192.168.68.91:8405/metrics) |
  | HAProxy (node1.streetrack.org) | Promtail | [http://192.168.68.91:9080](http://192.168.68.91:9080) |
  | Web Server 1 (node2.streetrack.org) | Web Server | [http://192.168.68.92:80](http://192.168.68.92:80) |
  | Web Server 1 (node2.streetrack.org) | Node Exporter | [http://192.168.68.92:9100](http://192.168.68.92:9100) |
  | Web Server 1 (node2.streetrack.org) | Promtail | [http://192.168.68.92:9080](http://192.168.68.92:9080) |
  | Web Server 2 (node3.streetrack.org) | Web Server | [http://192.168.68.93:80](http://192.168.68.93:80) |
  | Web Server 2 (node3.streetrack.org) | Node Exporter | [http://192.168.68.93:9100](http://192.168.68.93:9100) |
  | Web Server 2 (node3.streetrack.org) | Promtail | [http://192.168.68.93:9080](http://192.168.68.93:9080) |


### Troubleshooting
If you encounter issues during the Ansible playbook execution, check the Ansible logs for detailed error messages.
Ensure all prerequisites are correctly installed and configured before starting the installation.
For issues related to specific components, refer to the component's documentation or the troubleshooting section of this guide.
