![ha-webtrack](https://i.imgur.com/jQxEMtS.png)

## Overview

The HA-WEBTRACK project applies RHCSA and RHCE principles to create a high-availability web server environment using open-source tools. Automated with Ansible and secured by SELinux, this project streamlines infrastructure setup, logging, and alert rule implementation. We'll enhance system performance clarity by testing high loads and analyzing failover scenarios. By converting Ansible playbooks into roles, the project boosts installation efficiency and code reusability, providing a practical experience in system monitoring and metrics analysis.
> **CLONE THE REPO and TEST ITS FUNCTIONALITY!**

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
> **Note:** Throughout this project, all root and user *password: 'password'*
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
   **This command starts the installation and configuration of `ALL` components:**
   
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

- Results from running `site.yaml` playbook shows no errors. AWESOME!!!

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

- **A short and simple command to spin up our nodes' cpu**

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

<details close>
<summary> <h2>Testing</h2> </summary>
<details close>
<summary> <h4>Baseline</h4> </summary>
  
- **First lets confirm SELinux is set to Enforcing on all nodes**

![ha-webtrack](https://i.imgur.com/IfLaY6T.png)<br><br>

- **Here, we'll install httpd-tools where `ab` Apache benchmark can be used to generate http requests to our server for testing**

![ha-webtrack](https://i.imgur.com/V1Bjk1e.png)<br><br>

- **Next, we increase the maximum tracked connections (nf_conntrack_max) for handling high traffic**

![ha-webtrack](https://i.imgur.com/lONpkrF.png)<br><br>

- **A custom dashboard was created for this project and baseline metrics can now be taken and recorded**

![ha-webtrack](https://i.imgur.com/eDnLHnh.png)<br><br>
![ha-webtrack](https://i.imgur.com/32rgVYp.png)<br><br>

**HAProxy and Web Server Metrics Summary**

- HAProxy Disk Usage: 16.0%
- HAProxy Memory Usage: 12.5%
- Server Uptime: All servers (HAProxy, node2, node3) up for 1.43 hours
- Alerts: No alerts triggered
- Active Backend Servers: 2 (node2, node3)
  
CPU Usage: 
HAProxy:
  - Min: 0.475%, Max: 1.17%, Mean: 0.782%
  - Current: about 1%
   
Web Servers (node2 and node3):
- Node2: Min: 1.48%, Max: 2.99%, Mean: 2.38%
- Node3: Min: 1.69%, Max: 3.32%, Mean: 2.55%
- Current: about 3%

Load Average:
- HAProxy:
  - 1-minute: 0.2, 5-minute: 0.06, 15-minute: 0.02
- Web Servers:
  - Node2: 1-minute: 0.22
  - Node3: 1-minute: 0.29
    
Memory Usage for Web Servers:
- Node2: Min: 49.5%, Max: 49.5%, Mean: 49.5%
- Node3: Min: 47.7%, Max: 47.7%, Mean: 47.7%
- Current memory usage: about 50% (stable)
  
HTTP Request Rate for HAProxy:
- Current request rate: 0
  
Session Rate for Web Servers:
- Current session rate: 0

HAProxy Logs:
- No data available

**Overall Insights:**
- Low Traffic: Minimal network traffic and no HTTP requests, suggesting light usage
- Stable Performance: CPU and memory usage on both HAProxy and web servers are low and stable
- No Active Sessions: Both web servers show no active sessions, indicating no load on the system at the moment
</details>

<details close>
<summary> <h4>Moderate Load</h4> </summary>
  
- **ApacheBench used to generate moderate load with 10,000 requests and 5 concurrent users**

![ha-webtrack](https://i.imgur.com/qHvtZVn.png)<br><br>

- **Now lets take a look at the results**

![ha-webtrack](https://i.imgur.com/7qC0Hbm.png)<br><br>
![ha-webtrack](https://i.imgur.com/WR1PN6r.png)<br><br>

**HAProxy and Web Server Metrics Summary under Moderate Load**

- HAProxy Disk Usage: 16.0% (unchanged)
- HAProxy Memory Usage: 12.9% (slight increase from baseline)
- Server Uptime: All servers (HAProxy, node2, node3) up for 1.49 hours
- Alerts: No alerts triggered
- Active Backend Servers: 2 (node2, node3)

CPU Usage:
HAProxy:
- Min: 0.441%, Max: 52.9%, Mean: 2.34%
- Peak CPU usage reached 52.9% during load testing.

Web Servers (node2 and node3):
- Node2: Min: 1.48%, Max: 59.6%, Mean: 3.69%
- Node3: Min: 1.69%, Max: 89.7%, Mean: 4.63%
- CPU usage spiked on both web servers, with node3 seeing a significant increase.

Load Average:
- HAProxy:
  - 1-minute: 0.7, 5-minute: 0.18, 15-minute: 0.05
- Web Servers:
  - Node2: 1-minute: 0.24
  - Node3: 1-minute: 2.26 (significant increase due to high traffic)

Memory Usage for Web Servers:
- Node2: Min: 49.5%, Max: 50.0%, Mean: 49.6%
- Node3: Min: 47.7%, Max: 48.4%, Mean: 47.8%
- Memory usage remained stable on both web servers during the load test.

HTTP Request Rate for HAProxy:
- Peak request rate: 400 requests per second.

Session Rate for Web Servers:
- Session rate peaked during load with node2 and node3 equally handling requests which returned to normal after the test

HAProxy Logs:
- Log entries reflect successful requests and traffic management by HAProxy during the test.

**Insights:**
- Increased Traffic: The system handled a moderate load of 10,000 requests with a significant spike in both CPU usage and network traffic on HAProxy and web servers.
- Stable Memory Usage: Despite the load, memory usage remained stable on both web servers.
- Peak Performance: Node3 experienced higher CPU load compared to Node2, possibly due to more evenly distributed traffic.
- Evenly distributed requests: node2 and node3 webservers handled an equal number of requests confirming haproxy load balancing effective
- No Alerts: Despite the increased load, no alerts were triggered, indicating that the system is well-configured to handle moderate traffic without failures.
</details>

<details close>
<summary> <h4>High Load</h4> </summary>
  
- **Now we'll increase the numbe of requeststo 70.000 and 20 concurrent connections for this test.**

![ha-webtrack](https://i.imgur.com/iPW2sSK.png)<br><br>

- **After a few minutes, a high request rate alert was triggered and we received a notification in the slack channel**

![ha-webtrack](https://i.imgur.com/QNyWPVo.png)<br><br>

- **Navigating to prometheus alerts page, we can verify the the alert in a firing and active state. The alert rule can be verified and reviewed**

![ha-webtrack](https://i.imgur.com/oc4GcUL.png)<br><br>

- **Below are the screenshots of our custom grafana dashboard with metrics to observe**

![ha-webtrack](https://i.imgur.com/GtcVwPd.png)<br><br>
![ha-webtrack](https://i.imgur.com/vczTYu0.png)<br><br>

**HAProxy and Web Server Metrics Summary under High Load**

- HAProxy Disk Usage: 16.1% (slight increase)
- HAProxy Memory Usage: 12.6% (minimal change)
- Server Uptime: All servers (HAProxy, node2, node3) up for 1.61 hours.
- Alerts: 1 active alert (High Request Rate)
- Active Backend Servers: 2 (node2, node3)

CPU Usage:
- HAProxy:
  - Min: 0.441%, Max: 71.1%, Mean: 13.1%
  - Peak CPU usage spiked to 71.1% during high load.

- Web Servers (node2 and node3):
  - Node2: Min: 1.48%, Max: 72.1%, Mean: 13.9%
  - Node3: Min: 1.69%, Max: 98.3%, Mean: 19.3%
  - Node3 hit 98.3% CPU usage, indicating that it was handling a significant portion of the load.

Load Average:
- HAProxy:
  - 1-minute: 1.86, 5-minute: 0.77, 15-minute: 0.38
  - Significantly higher compared to the baseline and moderate load tests.

- Web Servers:
  - Node2: 1-minute: 2.2
  - Node3: 1-minute: 43.7 (major spike due to heavy traffic)

Memory Usage - Web Servers:
- Node2: Min: 49.5%, Max: 50.2%, Mean: 49.8%
- Node3: Min: 47.7%, Max: 59.0%, Mean: 51.3%
- Memory usage increased slightly on both web servers, with Node3 peaking at 59.0%.

HTTP Request Rate - HAProxy:
- Peak request rate: 400 requests per second.

Session Rate - Web Servers:
- Session rate is still balanced 50% between the two webserer nodes 

HAProxy Logs:
- The logs indicate successful handling of the increased load, showing HTTP requests and load balancing between the two web servers.

**Insights:**
- Increased Load: The system handled a much heavier load of 70,000 requests with significant spikes in CPU usage and network traffic.
- High CPU Usage: Both HAProxy and Node3 experienced high CPU usage, indicating that the system was operating near its maximum capacity.
- Triggered Alerts: The High Request Rate alert was successfully triggered, and notifications were sent to the Slack channel, demonstrating effective monitoring and alerting.
- Stable Memory: Despite the high load, memory usage remained stable on both web servers.
</details>

<details close>
<summary> <h4>Failover</h4> </summary>
  
- **For this scenario, we'll poweroff node3 to simulate a downed instance, run a moderate load test and observe the metrics**

![ha-webtrack](https://i.imgur.com/rIMeltf.png)<br><br>

- **After a few minutes, an instance down alert is triggered. We can see the firing state in the alerts page of our prometheus service**

![ha-webtrack](https://i.imgur.com/C512gdn.png)<br><br>

- **Consequently, a notification is received via our slack channel**

![ha-webtrack](https://i.imgur.com/R1BOpe1.png)<br><br>

- **Below are the screenshots of our custom grafana dashboard with metrics to observe**

![ha-webtrack](https://i.imgur.com/6YZ7qPW.png)<br><br>
![ha-webtrack](https://i.imgur.com/iBmA7dW.png)<br><br>
![ha-webtrack](https://i.imgur.com/M23WTjH.png)<br><br>
![ha-webtrack](https://i.imgur.com/oQPCzF0.png)<br><br>

**HAProxy and Web Server Metrics Summary during Failover**

- Active Backend Servers: 1 (node2)
  
CPU Usage:
- HAProxy CPU Usage:
  - Min: 0.441%, Max: 80.7%, Mean: 13.6%
  - A significant spike occurred when the failover happened, with CPU usage peaking at 80.7%.

Web Server CPU Usage (node2):
- Min: 1.55%, Max: 76.4%, Mean: 14.6%

Web Server CPU Usage (node3):
- Node3 showed no CPU usage after being powered off, as expected.

Load Average:
- HAProxy Load Average:
  - 1-minute: 1.86, 5-minute: 0.770, 15-minute: 0.354

Web Server Load Average:
- Node2: 1-minute load peaked at 2.20.
- Node3: Load showed 0 after being powered off, indicating no activity.

Memory Usage:
- Node2: Min: 49.7%, Max: 50.8%, Mean: 50.2%
- Node3: Min: 48.4%, Max: 60.2%, Mean: 57.2%
- Node2 memory usage remained stable as it took over the traffic after the failover.
- Node3 shows a break in the graph confirming the downed instance
  
HTTP Request Rate (HAProxy):
- Peaked at 400 requests/sec during the failover.
- After node3 was powered off, the request rate dropped temporarily but resumed at node2.

Session Rate (Web Servers):
- Node2 handled the traffic after failover with 188 sessions after the switch.
- Node3 showed 0 sessions after being powered off, confirming the failover to node2.

HAProxy Logs:
- Logs show the switch of traffic from node3 to node2, confirming successful failover behavior, with each HTTP request being rerouted.

**Overall Insights:**
- Successful Failover: After powering off node3, HAProxy successfully rerouted the traffic to node2.
- Spikes in CPU and Load: Both HAProxy and node2 experienced spikes in CPU usage and load during the transition, but performance remained stable.
- No Downtime: Traffic handling switched seamlessly, indicating a properly configured failover setup.
</details>
