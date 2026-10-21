# HA Retail — Azure Infrastructure & DevOps Project

A hands-on cloud engineering portfolio project demonstrating Azure networking, infrastructure as code, identity-based security, secrets management, Linux administration, CI/CD, and cloud troubleshooting.

## Project Overview

The goal is to build a secure, highly available retail application architecture on Microsoft Azure, using Terraform to provision infrastructure and GitHub Actions to automate website deployment.

**Current status:** The web and application VM infrastructure in South India and PostgreSQL infrastructure in UK South are deployed. Selected private-network connectivity checks and Key Vault endpoint access have passed. End-to-end application integration and high availability remain in progress.

The static storefront is hosted separately through Azure Static Web Apps.

## Architecture

The current infrastructure spans two Azure regions.

### South India — Web and Application Tiers

- Virtual network: `ha-retail-vnet` (`10.0.0.0/16`)
- Application Gateway subnet: `10.0.1.0/24` (reserved; no Application Gateway deployed)
- Web subnet: `10.0.2.0/24`
- Application subnet: `10.0.3.0/24`
- Web VM: `ha-retail-southindia-web-vm`, private IP `10.0.2.4`
- Application VM: `ha-retail-southindia-app-vm`, private IP `10.0.3.4`
- Both VMs use Ubuntu Linux and have no public IP addresses.
- Nginx is installed on the web VM.
- The application VM has a system-assigned managed identity.

### Azure Key Vault

- Key Vault: `hrkv6952055559284c2ca73a`
- Region: South India
- Authorization: Azure RBAC
- Network access: Default action `Deny`, with a virtual network rule for the application subnet
- Application subnet: Uses the `Microsoft.KeyVault` service endpoint
- Application VM identity: Assigned the `Key Vault Secrets User` role at the vault scope
- Recovery protection: Soft delete and purge protection enabled

The application VM successfully obtained a managed-identity token and received HTTP `200` from the Key Vault secrets endpoint.

**Important:** Actual retrieval of a specific secret value and application integration with Key Vault are still pending. The developer's Azure CLI identity is separate from the app VM identity and does not currently have the required secret-reading permission.

The vault retains a public endpoint with firewall restrictions. This is a service-endpoint design, not a private-endpoint deployment.

### UK South — Database Tier

- Virtual network: `ha-retail-southindia-postgresql-vnet` (`10.1.0.0/16`)
- Delegated PostgreSQL subnet: `10.1.1.0/24`
- Azure Database for PostgreSQL Flexible Server: `ha-retail-southindia-pg`
- PostgreSQL public network access is disabled.
- VNet peering and private DNS connect the database network with the South India network.

**Important:** PostgreSQL uses private networking through a delegated subnet. This is not an Azure Private Endpoint deployment.

## Technologies Used

- Microsoft Azure
- Terraform and AzureRM provider
- Azure CLI
- Azure Virtual Network, VNet peering, service endpoints, and Network Security Groups
- Azure Key Vault and Azure RBAC
- System-assigned managed identities
- Azure Database for PostgreSQL Flexible Server
- Azure Static Web Apps
- GitHub and GitHub Actions
- Ubuntu Linux and Nginx
- PowerShell and SSH

## Completed Work

### 1. Infrastructure as Code

- Configured Terraform and the AzureRM provider.
- Defined resource groups, virtual networks, subnets, VMs, VNet peering, private DNS, and PostgreSQL infrastructure.
- Updated `terraform-southindia/` to reflect the deployed infrastructure.
- Ran `terraform fmt` and `terraform validate` successfully.
- Confirmed that an earlier reconciliation plan reported no changes.
- Added Terraform configuration for Key Vault, the application subnet's Key Vault service endpoint, and the managed-identity role assignment.
- Successfully applied the Key Vault infrastructure changes.

### 2. Network Security

- Created separate web and application subnets.
- Configured the web subnet NSG to allow HTTP on TCP port 80 from the `VirtualNetwork` source scope.
- Configured the application subnet NSG to allow TCP port 8080 from the web subnet.
- Added inbound deny rules for other traffic within the configured source scope.
- Disabled public network access for PostgreSQL.
- The current Terraform configuration does not define a separate NSG for the PostgreSQL subnet.

The intended Web VM → App VM flow still needs testing with a service listening on port 8080.

### 3. Key Vault and Managed Identity

- Deployed Azure Key Vault using Terraform.
- Enabled RBAC authorization and configured default-deny network rules.
- Enabled the `Microsoft.KeyVault` service endpoint on the application subnet.
- Allowed the application subnet in the vault's virtual network rules.
- Enabled soft delete and purge protection.
- Assigned the `Key Vault Secrets User` role to the app VM's system-assigned managed identity.
- Verified the role assignment and vault configuration using Azure CLI.
- Verified that the application VM obtained a managed-identity token.
- Verified an authenticated request to the Key Vault secrets endpoint returned HTTP `200`.

Actual secret-value retrieval and application integration remain pending.

### 4. Static Storefront and CI/CD

- Built a static retail storefront using HTML and CSS.
- Deployed it using Azure Static Web Apps.
- Connected the GitHub repository to GitHub Actions.
- Previously verified automated storefront deployments.

The storefront is hosted independently of the Terraform-managed VM and database infrastructure. Storefront deployment does not mean the backend application and database are integrated.

### 5. Linux VM and Web Server Validation

- Investigated Azure VM SKU restrictions and regional availability.
- Deployed Ubuntu VMs in South India using Terraform.
- Used Azure Run Command to administer the VMs without opening inbound SSH access for these tests.
- Installed and enabled Nginx on the web VM.
- Verified a local HTTP response of `HTTP/1.1 200 OK`.
- Verified HTTP `200 OK` from the application VM to the web VM over the private network.
- Used Azure Run Command to execute diagnostic scripts on the application VM.

Both VMs were previously deallocated after testing and later restarted for further validation. Check their current status before assuming they are stopped.

### 6. PostgreSQL Network Validation

- Deployed Azure Database for PostgreSQL Flexible Server in UK South with public network access disabled.
- Configured cross-region VNet peering and private DNS links.
- Verified that the PostgreSQL hostname resolved to `10.1.1.4` from the application VM.
- Verified TCP connectivity from the application VM to PostgreSQL port 5432.

DNS resolution and TCP reachability do not prove that database authentication or SQL queries work. Those checks remain pending.

## Key Learning

A major troubleshooting lesson was that available vCPU quota does not guarantee that a particular VM SKU can be deployed. Regional SKU availability and subscription-specific restrictions must also be investigated.

The project also demonstrates the Terraform workflow: initialize, format, validate, plan, apply when changes are intended, verify, and destroy only when resources are intentionally being removed.

Another important distinction is that successful network connectivity does not prove application or database integration is working end to end.

The Key Vault work demonstrates that network restrictions and identity authorization are separate controls. A VM must have both an allowed network path and appropriate data-plane permissions. A managed identity provides authentication without requiring a separately stored client secret.

## Current Limitations

- A test service must be started on the application VM's TCP port 8080 before Web VM → App VM connectivity can be verified.
- Actual Key Vault secret retrieval has not yet been verified.
- PostgreSQL authentication and a test SQL query have not yet been verified.
- The backend application has not yet been integrated with PostgreSQL or Key Vault.
- An Application Gateway has not been deployed.
- Load balancing, monitoring, backup, and resilience testing remain unfinished.
- The Nginx local test did not verify public website access.
- High availability has not yet been implemented or demonstrated.

## Next Steps

1. Create a harmless test secret using an appropriately authorized identity and verify retrieval from the app VM without printing the secret value.
2. Start or confirm the VMs are running and run a test service on the application VM's TCP port 8080.
3. Test Web VM → App VM connectivity and record the actual result.
4. Securely authenticate to PostgreSQL and execute a test SQL query.
5. Deploy the application service and integrate it with PostgreSQL and Key Vault.
6. Configure and validate Application Gateway if required by the final design.
7. Add monitoring, backup, and resilience testing.
8. Document deployment, cleanup, and cost-management procedures.

## Repository Structure

- `terraform/` — Original Terraform configuration.
- `terraform-southindia/` — Terraform configuration for the current South India and UK South infrastructure.
- `website/` — Static storefront source.
- `docs/PROGRESS.md` — Development log and validation results.
- `docs/architecture-decisions.md` — Architecture choices and troubleshooting notes.
- `.github/workflows/` — GitHub Actions workflow.

Terraform state, provider working files, credentials, and secret variable files must not be committed to Git.

## Cost Awareness

Both VMs and PostgreSQL were restarted for recent validation after previously being stopped. Check their current status before ending a work session.

Deallocating VMs and stopping PostgreSQL reduce compute charges but do not eliminate all costs. Disks, backups, DNS, networking, Key Vault, and other retained services may continue to incur charges. PostgreSQL may automatically restart after Azure's permitted stopped period. Review resource status and Azure Cost Management regularly.

## Repository

GitHub: https://github.com/varuganti-pavan-kumar/ha-retail-project

**Project status:** In progress — Azure Cloud Engineering portfolio project.
