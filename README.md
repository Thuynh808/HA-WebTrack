# HA-WEBTRACK Project

## Overview

The HA-WEBTRACK project utilizes RHCSA and RHCE principles to develop a high-availability web server monitoring environment with open-source tools. Automated with Ansible and secured by SELinux, the setup includes establishing infrastructure, implementing alert rules, and creating a monitoring dashboard. The project further extends to testing system robustness through generating high load and analyzing failover. Converting Ansible playbooks into roles has streamlined installation and management, enhancing code reusability and update efficiency. This structured approach offers practical experience in system monitoring and metrics analysis.

### Key Components

- **VirtualBox**: Manages a secure virtual environment for all server roles including the control node, HAProxy, and web servers.
- **Red Hat Enterprise Linux (RHEL) VMs**: Provides a stable and secure operating base for all nodes.
- **Ansible**: Automates provisioning, configuration, and management of the server infrastructure.
- **HAProxy**: Balances load across web servers to enhance service reliability.
- **Apache HTTPD**: Serves web content efficiently on the web servers.
- **Prometheus** and **Grafana**: Monitor system performance with real-time metrics visualization.
- **Loki** and **Promtail**: Handle log aggregation and shipping, ensuring detailed logging.
- **Node Exporter**: Gathers comprehensive system metrics for monitoring.
- **Alertmanager**: Integrates with Slack to send real-time alerts, enhancing incident response capabilities.
- **GitHub**: Hosts project code for version control and collaborative development.

### Versions of Tools Used

This section outlines the specific versions of the tools and technologies deployed ensuring compatibility and stability across all components:

| Component              | Version                   |
|------------------------|---------------------------|
| VirtualBox: 7.0.14     | Grafana-Enterprise: 11.2  | 
| RHEL VMs: 9.4          | Loki: 3.2                 |
| Ansible: 2.14          | Promtail: 3.2             |
| HAProxy: 2.4           | Node Exporter: 1.8        |
| Apache HTTPD: 2.4      | Alertmanager: 0.27        |
| Prometheus: 2.54       | GitHub: Latest            |

## Getting Started

### Prerequisites
Before we begin, ensure the following are prepared:
- **Four Red Hat RHEL 9 VMs**: These will act as our control node, load balancer (HAProxy), and two web servers
> **Note:** *root password: 'password'*
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
- **Insert the RHEL ISO on control node** <br><br>
- **Run the command to mount the ISO:** <br><br>
  ```bash
  sudo mount /dev/sr0 /mnt
  ```
- **Add and configure the repository from the ISO:** <br><br>
  ```bash
  dnf config-manager --add-repo=file:///mnt/AppStream
  dnf config-manager --add-repo=file:///mnt/BaseOS
  echo "gpgcheck=0" >> /etc/yum.repos.d/mnt_AppStream.repo
  echo "gpgcheck=0" >> /etc/yum.repos.d/mnt_BaseOS.repo
  ```
- **Install `git` and `ansible-core`:** <br><br>
  ```bash
  dnf install -y git ansible-core
  ```
- **Create `ansible` user on `control node` and set password:** <br><br>
  ```bash
  useradd ansible
  passwd ansible # Follow prompts to set password
  ```
- **Add the `ansible` user to the `sudoers` file to grant necessary privileges and switch to `ansible` user:** <br><br>
  ```bash
  sudo echo 'ansible ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ansible
  su - ansible
  ```
- **Set up an SSH key pair:** <br><br>
  ```bash
  ssh-keygen # Press enter 3x to accept the default file location and no passphrase
  ```

### Installation
To install and set up the project, follow these steps:

1. **Clone the repository:** <br><br>
   ```bash
   git clone https://github.com/Thuynh808/HA-WebTrack
   cd HA-WebTrack
   ```
2. **Install required Ansible collections:** <br><br>
   ```bash
   ansible-galaxy collection install -r requirements.yaml
   ```
3. **Confirm Mount the RHEL ISO:** <br><br>
   ```bash
   sudo mount /dev/sr0 /mnt
   ```
4. **Configure inventory `ansible_host`:** <br><br>
   ```bash
   vim inventory
   ```
> **Note:** Replace IP addresses for all 4 servers and control node's fqdn and hostname according to your setup
5. **Run the initial setup script:** <br><br>
   ```bash
   ./initial-setup.sh
   ```
   **This script prepares our ansible environment by setting up necessary ansible user, host configurations, ssh-keys and repositories.** <br><br>
   *ansible user password: 'password'*

> **Note:** before installing components, add your slack webhook url for alertmanager to send alerts
6. **Edit alertmanager config file:** <br><br>
   ```bash
   vim roles/alertmanager/templates/alertmanager_config.j2
   ```
7. **Execute the main Ansible playbook:** <br><br>
   ```bash
   ansible-playbook site.yaml -vv
   ```
   **This command starts the configuration of all components as defined in the playbook. The -vv option increases verbosity, which can help with troubleshooting if needed.**

### Verification
After installation, verify that all components are running correctly by accessing the following URLs and ensuring that each service is operational:

### Services and URLs

  | Server | Service Name | URL |
  |--------|--------------|-----|
  | Control Node | Grafana | &lt;controlnode_ip&gt;:3000 |
  | Control Node | Prometheus | &lt;controlnode_ip&gt;:9090 |
  | Control Node | Loki(through Grafana) | &lt;controlnode_ip&gt;:3000 |
  | Control Node | Alertmanager | &lt;controlnode_ip&gt;:9093 |
  | HAProxy (node1) | HAProxy | &lt;node1_ip&gt;:80 |
  | HAProxy (node1) | Node Exporter | &lt;node1_ip&gt;:9100 |
  | HAProxy (node1) | HAProxy Exports | &lt;node1_ip&gt;:8405/metrics |
  | HAProxy (node1) | Promtail | &lt;node1_ip&gt;:9080 |
  | Web Server 1 (node2) | Web Server | &lt;node2_ip&gt;:80 |
  | Web Server 1 (node2) | Node Exporter | &lt;node2_ip&gt;:9100 |
  | Web Server 1 (node2) | Promtail | &lt;node2_ip&gt;:9080 |
  | Web Server 2 (node3) | Web Server | &lt;node3_ip&gt;:80 |
  | Web Server 2 (node3) | Node Exporter | &lt;node3_ip&gt;:9100 |
  | Web Server 2 (node3) | Promtail | &lt;node3_ip&gt;:9080 |


### Troubleshooting
When encountering issues during the Ansible playbook execution, check the Ansible logs for detailed error messages.
Ensure all prerequisites are correctly installed and configured before starting the installation.
For issues related to specific components, refer to the component's documentation or the troubleshooting section of this guide.
