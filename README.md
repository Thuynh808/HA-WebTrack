# HA-WEBTRACK Project

## Overview
The HA-WEBTRACK project is designed to create a high-availability web server environment using a variety of open-source tools. This infrastructure includes load balancing with HAProxy, web serving with Apache HTTPD, and comprehensive monitoring and logging with Prometheus, Grafana, Loki, and Alertmanager. The entire deployment and configuration are automated using Ansible.

## Getting Started

### Prerequisites
Before you begin, ensure you have the following prepared:
- **Four Red Hat RHEL 9 VMs**: These will act as your control node, load balancer (HAProxy), and two web servers.
- **Network Configuration**: Set IP addresses and hostnames for each VM using tools like `nmtui` to ensure proper networking. Ensure that the networking mode is set to `Bridge Adapter` to allow the VMs to directly communicate with the network as independent devices.

### Server Specifications
Below is a table outlining the specifications for each server used in the project:

| Server        | Role            | CPU | RAM  | Additional Notes                    |
|---------------|-----------------|-----|------|-------------------------------------|
| Control Node  | Management      | 2   | 4 GB | Second disk provisioned (min 20 GB) |
| Node1 (HAProxy) | Load Balancer | 2   | 4 GB |                                     |
| Node2 (WebServer) | Web Server  | 1   | 1 GB |                                     |
| Node3 (WebServer) | Web Server  | 1   | 1 GB |                                     |

> **Note:** Ensure each server meets or exceeds the specifications listed to ensure optimal performance and reliability of the HA-WEBTRACK environment.

### Setup Environment
- **Insert the RHEL ISO on control node**
- **Run the command to mount the ISO:**
  ```bash
  sudo mount /dev/sr0 /mnt
  ```
- **Add and configure the repository from the ISO:**
  ```bash
  dnf config-manager --add-repo=file:///mnt/AppStream
  dnf config-manager --add-repo=file:///mnt/BaseOS
  echo "gpgcheck=0" >> /etc/yum.repos.d/mnt_AppStream.repo
  echo "gpgcheck=0" >> /etc/yum.repos.d/mnt_BaseOS.repo
  ```
- **Install `git` and `ansible-core`:**
  ```bash
  dnf install -y git ansible-core
  ```
- **Create `ansible` user on `control node` and set password:**
  ```bash
  useradd ansible
  passwd ansible # Follow prompts to set password
  ```
- **Add the `ansible` user to the `sudoers` file to grant necessary privileges:**
  ```bash
  sudo echo 'ansible ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ansible
  ```
- **Switch to the ansible user and set up an SSH key pair:**
  ```bash
  su - ansible
  ssh-keygen # Press enter (3x) to accept the default file location and no passphrase
  ```

### Installation
To install and set up the project, follow these steps:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Thuynh808/HA-WebTrack
   cd HA-WebTrack
   ```
2. **Install required Ansible collections:**
   ```bash
   ansible-galaxy collection install -r requirements.yaml
   ```
3. **Confirm Mount the RHEL ISO:**
   ```bash
   sudo mount /dev/sr0 /mnt
   ```
4. **Configure inventory `ansible_host`:**
   ```bash
   vim inventory
   ```
> **Note:** Make sure to change IP addresses for all 4 servers according to your setup
5. **Run the initial setup script:**
   ```bash
   ./initial-setup.sh
   ```
   **This script prepares our ansible environment by setting up necessary ansible user, host configurations, ssh-keys and repositories.** 
   *ansible user password: 'password'*

> **Note:** before installing components, add your slack webhook url for alertmanager to send alerts
6. **Edit alertmanager config file:**   
   ```bash
   vim roles/alertmanager/templates/alertmanager_config.j2
   ```
7. **Execute the main Ansible playbook:**
   ```bash
   ansible-playbook site.yaml -vv
   ```
   This command starts the configuration of all components as defined in the playbook. The -vv option increases verbosity, which can help with troubleshooting if needed.

### Verification
After installation, verify that all components are running correctly by accessing the following URLs and ensuring that each service is operational:

### Services and URLs

  | Server | Service Name | URL |
  |--------|--------------|-----|
  | Control Node | Grafana | &lt;controlnode_ip&gt;:3000 |
  | Control Node | Prometheus | &lt;controlnode_ip&gt;:9090 |
  | Control Node | Loki(through Grafana) | &lt;controlnode_ip&gt;:3000 |
  | Control Node | Alertmanager | &lt;controlnode_ip&gt;:9093 |
  | HAProxy (node1.streetrack.org) | HAProxy | &lt;node1_ip&gt;:80 |
  | HAProxy (node1.streetrack.org) | Node Exporter | &lt;node1_ip&gt;:9100 |
  | HAProxy (node1.streetrack.org) | HAProxy Exports | &lt;node1_ip&gt;:8405/metrics |
  | HAProxy (node1.streetrack.org) | Promtail | &lt;node1_ip&gt;:9080 |
  | Web Server 1 (node2.streetrack.org) | Web Server | &lt;node2_ip&gt;:80 |
  | Web Server 1 (node2.streetrack.org) | Node Exporter | &lt;node2_ip&gt;:9100 |
  | Web Server 1 (node2.streetrack.org) | Promtail | &lt;node2_ip&gt;:9080 |
  | Web Server 2 (node3.streetrack.org) | Web Server | &lt;node3_ip&gt;:80 |
  | Web Server 2 (node3.streetrack.org) | Node Exporter | &lt;node3_ip&gt;:9100 |
  | Web Server 2 (node3.streetrack.org) | Promtail | &lt;node3_ip&gt;:9080 |


### Troubleshooting
If you encounter issues during the Ansible playbook execution, check the Ansible logs for detailed error messages.
Ensure all prerequisites are correctly installed and configured before starting the installation.
For issues related to specific components, refer to the component's documentation or the troubleshooting section of this guide.
