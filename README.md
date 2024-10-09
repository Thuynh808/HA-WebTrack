![ha-webtrack](https://i.imgur.com/jQxEMtS.png)

## Overview

The HA-WEBTRACK project applies RHCSA and RHCE principles to create a high-availability web server environment using open-source tools. Automated with Ansible and secured by SELinux, this project streamlines infrastructure setup, logging, and alert rule implementation. We'll enhance system performance clarity by testing high loads and analyzing failover scenarios. By converting Ansible playbooks into roles, the project boosts installation efficiency and code reusability, providing a practical experience in system monitoring and metrics analysis.

### Key Components

- **VirtualBox**: Manages a secure virtual environment for all server roles including the control node, HAProxy, and web servers.
- **Red Hat Enterprise Linux (RHEL) VMs**: Provides a stable and secure operating base for all nodes.
- **Ansible**: Automates configuration and management of the server infrastructure.
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
> **Note:** Throughout this project, all servers and users *root password: 'password'*
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
   **This script prepares our ansible environment:**
   
   - Configure /etc/hosts file for all nodes
   - Setup ftp server on control node as repository
   - Add repo to all nodes
   - Ensure python is installed on nodes
   - Create ansible user with password: *password*
   - Give ansible user sudo permissions
   - Copy ansible user public key to all nodes
   - Use rhel-system-roles-timesync to synchronize all nodes 
   <br><br>

> **Note:** Before installing components, add your slack webhook url for alertmanager to send alerts
6. **Edit alertmanager config file:** <br><br>
   ```bash
   vim roles/alertmanager/templates/alertmanager_config.j2
   ```
7. **Execute the main Ansible playbook:** <br><br>
   ```bash
   ansible-playbook site.yaml -vv
   ```
   **This command starts the installation and configuration of `ALL` components for this project. The -vv option increases verbosity, which can help with troubleshooting if needed.**
   
   - Apache HTTPD on `webservers` group
   - HAProxy load balancer on `balancers` group
   - Grafana on `control` node
   - Node Exporter on `balancers` and `webservers` group
   - Prometheus on `control` node
   - Promtail on `balancers` and `webservers` group
   - LVM storage for Loki logs on control node
   - Loki on `control` node
   - Alertmanager on `control` node

> **Note:** You can also run individual playbooks for each component if there's any timeout errors.
- **Run individual playbooks:** <br><br>
  ```bash
  ansible-playbook playbooks/<playbook_name>.yaml
  ```
---

### Verification

- Results from running site.yaml playbook shows no errors. AWESOME!!!

![ha-webtrack](https://i.imgur.com/tZGFdqv.png)<br><br>

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

---

## Project Highlights

This section showcases key milestones and achievements during the build and testing phases of the HA-WEBTRACK project. The following screenshots illustrate the successful deployment, configuration, and operation of the high-availability web server environment.

<details close>
<summary> <h2>The Build</h2> </summary>
<details close>
<summary> <h4>Initial Setup</h4> </summary>
  
- **Utilizing jinja2 template and ansbile facts to automate hosts file configurations for smooth and consistent idenitification of our nodes**

![ha-webtrack](https://i.imgur.com/yw6GNTm.png)
![ha-webtrack](https://i.imgur.com/NZgQve4.png)<br><br>

- **Successfully configured ftp server to host our repository**

![ha-webtrack](https://i.imgur.com/uNCO4iO.png)<br><br>

- **Using ansible debug module to create an encrypted password for user ansible**

![ha-webtrack](https://i.imgur.com/CJyS2WD.png)
</details>

<details close>
<summary> <h4>Webserver</h4> </summary>
  
- **Created a landing page with server info for webservers using jinja2 templating**

![ha-webtrack](https://i.imgur.com/u7g5tS0.png)<br><br>

- **Confirming `node2` and `node3` httpd service is up and running on port 80**

![ha-webtrack](https://i.imgur.com/akogaV0.png)
</details>

<details close>
<summary> <h4>HAProxy</h4> </summary>
  
- **Confirming `node1` haproxy service is up and running on port 80**

![ha-webtrack](https://i.imgur.com/h88Ub3Q.png)<br><br>

- **HAProxy metrics are showing on port 8405; `node2` & `node3` webservers are up**

![ha-webtrack](https://i.imgur.com/QpOhJyk.png)<br><br>

- **Navigating and refreshing on `node1`, we can see both webservers are coming up confirming http requests are load balanced**

![ha-webtrack](https://i.imgur.com/U8b26NC.png)
![ha-webtrack](https://i.imgur.com/blAczgE.png)
</details>

<details close>
<summary> <h4>Grafana</h4> </summary>
  
- **Confirming `control node` grafana service is up and running on port 3000**

![ha-webtrack](https://i.imgur.com/ECgsxky.png)<br><br>

- **Navigating to `control node` ip address on port 3000, we can access grafana using username: *admin* password: *admin***

![ha-webtrack](https://i.imgur.com/Y41iCPa.png)
</details>

<details close>
<summary> <h4>Node Exporter</h4> </summary>
  
- **Confirming node exporter is up and running on port 9100 for `node1` `node2` and `node3`**

![ha-webtrack](https://i.imgur.com/QhI8dR4.png)<br><br>

- **Navigating to `node2` metrics, we can see node exporter successfully pulled data from the system**

![ha-webtrack](https://i.imgur.com/NkuER0p.png)
</details>

<details close>
<summary> <h4>Prometheus</h4> </summary>
  
- **Confirming prometheus is up and running on port 9090 for `control node`**

![ha-webtrack](https://i.imgur.com/LcFK00Z.png)<br><br>

- **Navigating to `control node` on port 9090, we can confirm all our nodes are up**

![ha-webtrack](https://i.imgur.com/9hM59cV.png)<br><br>

- **After adding prometheus data source to grafana, we can import a prebuilt dashboard `159` for quick visualization**

![ha-webtrack](https://i.imgur.com/VEV6Ksy.png)<br><br>

- **A short script to spin up our nodes' cpu**

![ha-webtrack](https://i.imgur.com/Pj8AcoB.png)<br><br>

- **Our dashboard shows our nodes' uptime, as well as available memory. We can also see the spike of load average and cpu usage from the previous command**

![ha-webtrack](https://i.imgur.com/sGiHyht.png)
</details>

<details close>
<summary> <h4>Promtail/Loki</h4> </summary>
  
- **Confirming promtail is up and running on port 9080 for `node1` `node2` and `node3`**

![ha-webtrack](https://i.imgur.com/iCJqKRR.png)<br><br>

- **We can see the different logs being pulled when navigating to promtail's port**

![ha-webtrack](https://i.imgur.com/uSEVMkC.png)<br><br>

- **Confirming loki is up and running on port 3100 for `control node`**

![ha-webtrack](https://i.imgur.com/ye8PtPt.png)<br><br>

- **After adding loki data source in grafana, logs are successfully populated for analyzing**

![ha-webtrack](https://i.imgur.com/8NEKP8t.png)
</details>

<details close>
<summary> <h4>Alertmanager</h4> </summary>
  
- **Alermanager started and running on port 9093**

![ha-webtrack](https://i.imgur.com/g3GA5YN.png)<br><br>

- **Navigating to `control node` on port 9093, we can confirm alertmanager is up**

![ha-webtrack](https://i.imgur.com/Cox4P8v.png)<br><br>

- **When navigating to alerts section in prometheus port on `control node`, we can see our alerts are up and none active**

![ha-webtrack](https://i.imgur.com/OontrSP.png)<br><br>

- **In the rules section of prometheus, we have promql queries used to defined our alert rules**

![ha-webtrack](https://i.imgur.com/m8M70fH.png)
</details>
</details>
