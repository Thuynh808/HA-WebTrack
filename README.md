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

- insert rhel iso
- run command to mount the iso
  ```bash
  sudo mount /dev/sr0 /mnt
  ```
- add and configure repo from iso
  ```bash
  dnf config-manager --add-repo=file:///mnt/AppStream
  dnf config-manager --add-repo=file:///mnt/BaseOS
  echo "gpgcheck=0" >> /etc/yum.repos.d/mnt_AppStream.repo
  echo "gpgcheck=0" >> /etc/yum.repos.d/mnt_BaseOS.repo
  ```
- install git and ansible-core
  ```bash
  dnf install -y git ansible-core
  ```
   
- **Ansible User**:
  - Create an `ansible` user on localhost and set password to `password`:<br><br>
  ```bash
  useradd ansible
  passwd ansible
  ```
  - Add the `ansible` user to the `sudoers` file to grant necessary privileges:<br><br>
  ```bash
  sudo echo 'ansible ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ansible
  ```
  
    - Switch to ansible user:<br><br>
  ```bash
  su - ansible
  ```
  - Set up an SSH key pair for the `ansible` user with:<br><br>
  ```bash
  ssh-keygen
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
4. **confirm Mount the rhel iso:**

   ```bash
   sudo mount /dev/sr0 /mnt
   ```
6. configure inventory ansible_host
   ```bash
   vim inventory
   ```
   change ipaddresses for all 4 servers
5. **Run the initial setup script:**
   
   ```bash
   ./initial-setup.sh
   ```
   This script prepares our ansible environment by setting up necessary ansible user, hosts configurations and prerequisites.


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
  | HAProxy (node1.streetrack.org) | Node Exporter | &lt;node1_ip&gt:9100 |
  | HAProxy (node1.streetrack.org) | HAProxy Exports | &lt;node1_ip&gt:8405/metrics |
  | HAProxy (node1.streetrack.org) | Promtail | &lt;node1_ip&gt:9080 |
  | Web Server 1 (node2.streetrack.org) | Web Server | &lt;node2_ip&gt:80 |
  | Web Server 1 (node2.streetrack.org) | Node Exporter | &lt;node2_ip&gt:9100 |
  | Web Server 1 (node2.streetrack.org) | Promtail | &lt;node2_ip&gt:9080 |
  | Web Server 2 (node3.streetrack.org) | Web Server | &lt;node3_ip&gt:80 |
  | Web Server 2 (node3.streetrack.org) | Node Exporter | &lt;node3_ip&gt:9100 |
  | Web Server 2 (node3.streetrack.org) | Promtail | &lt;node3_ip&gt:9080 |


### Troubleshooting
If you encounter issues during the Ansible playbook execution, check the Ansible logs for detailed error messages.
Ensure all prerequisites are correctly installed and configured before starting the installation.
For issues related to specific components, refer to the component's documentation or the troubleshooting section of this guide.
