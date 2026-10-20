# Architecture Decisions and Troubleshooting

## 1. Project Overview

This is a hands-on Azure retail infrastructure project managed with Terraform. The goal is to learn and demonstrate cloud networking, Linux virtual machines, network security, private database connectivity, deployment automation, and high-availability design.

**Current status:** The infrastructure foundation is deployed and selected network checks have passed. The complete three-tier application and its high-availability mechanisms are not yet implemented or verified.

## 2. Current Architecture

### South India — Web and Application Infrastructure

- Resource group: `ha-retail-southindia`
- Virtual network: `ha-retail-vnet`
- Address space: `10.0.0.0/16`

| Component | Configuration |
|---|---|
| Application Gateway subnet | `10.0.1.0/24` |
| Web subnet | `10.0.2.0/24` |
| Application subnet | `10.0.3.0/24` |
| Web VM | `ha-retail-southindia-web-vm` |
| Web VM private IP | `10.0.2.4` |
| Web server | Nginx on Ubuntu 22.04 |
| Application VM | `ha-retail-southindia-app-vm` |
| Application VM private IP | `10.0.3.4` |
| VM size | `Standard_B2ats_v2` |

Both VMs have private IP addresses and no public IP addresses. SSH password authentication is disabled, and an SSH public key is configured for administration.

The application VM has the PostgreSQL command-line client installed. A working application service listening on TCP port 8080 has not yet been verified.

The Application Gateway subnet exists, but **Application Gateway itself has not been deployed**.

### Network Security Groups

The web subnet's NSG allows inbound TCP port 80 from the `VirtualNetwork` source scope and includes a deny rule for other inbound traffic matching that scope.

The application subnet's NSG allows inbound TCP port 8080 from `10.0.2.0/24` and includes a deny rule for other inbound traffic matching the `VirtualNetwork` source scope.

These rules express the intended network policy, but the Web VM-to-App VM flow still requires testing.

The current Terraform configuration does not define a separate NSG for the PostgreSQL subnet. PostgreSQL public network access is disabled.

### UK South — Database Infrastructure

- Resource group: `ha-retail-southindia-postgresql-uksouth`
- Virtual network: `ha-retail-southindia-postgresql-vnet`
- Address space: `10.1.0.0/16`

| Component | Configuration |
|---|---|
| PostgreSQL subnet | `10.1.1.0/24` |
| Database service | Azure Database for PostgreSQL Flexible Server |
| Server name | `ha-retail-southindia-pg` |
| PostgreSQL private IP observed in testing | `10.1.1.4` |
| PostgreSQL version | 18 |
| Public network access | Disabled |

The PostgreSQL subnet is delegated to `Microsoft.DBforPostgreSQL/flexibleServers`.

**Important:** This is PostgreSQL Flexible Server private networking through a delegated subnet, not an Azure Private Endpoint deployment.

### Cross-Region Connectivity

Bidirectional VNet peering connects the South India and UK South virtual networks.

The PostgreSQL private DNS zone is linked to both virtual networks. This allows clients in the South India network to resolve the PostgreSQL hostname to its private address.

DNS resolution and TCP connectivity have been verified from the application VM. These results confirm selected parts of the network path, not successful database authentication or application integration.

## 3. Architecture Decisions

### Why the infrastructure uses two regions

The VM deployment encountered regional SKU and subscription quota restrictions during troubleshooting. South India was selected for the web and application VMs after checking available VM sizes and quota.

PostgreSQL Flexible Server was deployed in UK South, where the selected configuration was available.

**Trade-offs:** Cross-region communication introduces network latency and may incur data-transfer charges. This arrangement does not, by itself, make the application highly available.

### Why the VM size changed

Initial VM deployment attempts encountered SKU availability and quota restrictions. Azure CLI was used to inspect available SKUs and regional quota.

The `Standard_B2ats_v2` size was selected, and both VMs deployed successfully.

### Why PostgreSQL uses a delegated subnet

PostgreSQL Flexible Server is configured for private networking through a delegated subnet, with public network access disabled.

This reduces exposure to the public internet. Database authentication and actual SQL query execution still need to be validated.

### Why private DNS is linked to both virtual networks

The database hostname must resolve correctly from the application network as well as the database network. Linking the private DNS zone to both VNets supports this requirement.

### Why VNet peering is configured in both directions

Peering resources are configured on both VNets with virtual network access enabled. This provides the intended network connectivity between the two regions, subject to routing, NSG rules, and service configuration.

## 4. Troubleshooting and Validation Results

### VM deployment

- Investigated regional VM SKU availability and vCPU quotas.
- Selected `Standard_B2ats_v2`.
- Successfully deployed the web and application VMs.

### Nginx local test — Passed

Nginx was installed on the web VM and enabled to start automatically.

A request to `http://localhost` on the web VM returned `HTTP/1.1 200 OK`.

This verifies that Nginx responded locally on the web VM.

### App VM to Web VM — Passed

From the application VM, a request was sent to `http://10.0.2.4`.

The request returned `HTTP/1.1 200 OK`.

This verifies **App VM → Web VM** connectivity over the private network. It does not verify the intended Web VM → App VM application flow.

### Web VM to App VM — Not yet verified

The intended application flow is Web VM → App VM over TCP port 8080.

A test service must first be started on the application VM. Then a request must be sent from the web VM to `10.0.3.4:8080`, and a successful response must be observed.

Until this test passes, the Web-to-App flow must not be described as verified.

### PostgreSQL DNS — Passed

From the application VM, the PostgreSQL hostname resolved to private IP `10.1.1.4`.

### PostgreSQL TCP connectivity — Passed

A TCP connectivity test from the application VM to PostgreSQL port 5432 succeeded.

This proves TCP reachability, not successful database authentication or SQL execution.

### PostgreSQL authentication and query — Pending

Successful login and execution of a test SQL query have not yet been verified. These checks remain necessary before claiming that the application tier is integrated with the database.

## 5. Terraform Configuration Reconciliation

After provisioning, the Terraform source was updated to match the deployed configuration.

Two differences were corrected:

- The PostgreSQL Flexible Server availability zone was set to match the deployed zone (`3`).
- The PostgreSQL subnet's `Microsoft.Storage` service endpoint was added to match the deployed subnet configuration.

After these updates, `terraform fmt` and `terraform validate` succeeded, and `terraform plan` reported: `No changes. Your infrastructure matches the configuration.`

This illustrates an important Infrastructure as Code practice: keep Terraform configuration, state, and the intended deployed infrastructure aligned. A no-change plan means Terraform currently detects no changes to make; it does not prove every application or network flow works.

The changes were committed and pushed in commit `76b915c` (`Align Terraform with deployed multi-region infrastructure`). Terraform state files and `.terraform/` were ignored by Git.

## 6. Cost Management

After infrastructure tests, both VMs were deallocated and PostgreSQL was stopped.

Deallocating VMs and stopping PostgreSQL reduce compute charges but do not guarantee zero ongoing cost. Managed database storage and backups, VM disks, DNS, networking, and other retained resources may still incur charges.

The PostgreSQL server may automatically restart after its permitted stopped period. Check its state before assuming it remains stopped, and review Azure Cost Management for actual charges.

## 7. Security Improvements

Planned improvements include:

- Store credentials in Azure Key Vault.
- Evaluate managed identities and Microsoft Entra authentication where supported.
- Review and tighten NSG rules to allow only required traffic.
- Avoid exposing passwords in command history, scripts, logs, or source control.
- Keep Terraform state private because it may contain sensitive values.
- Verify that only intended network paths can reach application and database services.

## 8. Remaining Work

1. Start the VMs and validate Web VM → App VM connectivity on TCP port 8080 using a test service.
2. Securely validate PostgreSQL authentication and run a test SQL query.
3. Deploy the application service and integrate it with PostgreSQL.
4. Configure and test Application Gateway if required by the final design.
5. Implement monitoring, backup, recovery, and resilience tests.
6. Review costs, document deployment and cleanup procedures, and verify the final architecture end to end.

**Project status:** Infrastructure deployed; some private connectivity checks passed; application integration and high availability remain unfinished.