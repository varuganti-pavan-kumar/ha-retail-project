# Project Development Log

This file tracks completed milestones, implementation progress, troubleshooting, validation results, and remaining work for the HA Retail Azure project.

**Last updated:** 2026-10-20  
**Overall status:** Infrastructure deployed; end-to-end application validation in progress.

## Milestone 1 — Terraform Foundation

**Status: Completed**

- Configured the Terraform Azure provider and version constraints.
- Added project variables and `.gitignore` rules.
- Ran Terraform formatting, validation, and planning.
- Created a separate Terraform configuration in `terraform-southindia/` for the South India infrastructure.
- Updated the Terraform source to match the deployed resources, including the PostgreSQL availability zone and subnet service endpoint configuration.
- Confirmed `terraform validate` succeeds and `terraform plan` reports no changes.
- Committed and pushed the Terraform update in commit `76b915c` (`Align Terraform with deployed multi-region infrastructure`).

## Milestone 2 — South India Network Foundation

**Status: Deployed**

- Created resource group `ha-retail-southindia`.
- Created virtual network `ha-retail-vnet` with address space `10.0.0.0/16`.
- Created the reserved Application Gateway subnet `10.0.1.0/24`.
- Created the web subnet `10.0.2.0/24`.
- Created the application subnet `10.0.3.0/24`.
- Configured Network Security Groups for the web and application subnets.
- Deployed web and application Linux VMs without public IP addresses.

## Milestone 3 — Web Server Setup and Validation

**Status: Local test passed**

- Installed Nginx on the web VM.
- Enabled Nginx to start automatically.
- Tested `http://localhost` on the web VM.
- Received `HTTP/1.1 200 OK`, confirming that Nginx responded locally.

This test did not verify public website access.

## Milestone 4 — Private Network Connectivity

**Status: Partially verified**

- Sent an HTTP request from the application VM to the web VM at `10.0.2.4`.
- Received `HTTP/1.1 200 OK`.
- Confirmed that the application VM could reach Nginx on the web VM over the private network.

**Important limitation:** This test verified App VM → Web VM connectivity. The intended Web VM → App VM flow on TCP port 8080 has not yet been tested successfully. A service must be listening on the application VM's port 8080 before this test can be completed.

## Milestone 5 — PostgreSQL Infrastructure

**Status: Deployed; network checks passed**

- Created a separate resource group and virtual network in UK South.
- Created the delegated PostgreSQL subnet `10.1.1.0/24`.
- Deployed Azure Database for PostgreSQL Flexible Server with public network access disabled.
- Configured bidirectional VNet peering between South India and UK South.
- Linked the PostgreSQL private DNS zone to both virtual networks.
- Verified that the PostgreSQL hostname resolved to `10.1.1.4` from the application VM.
- Verified TCP connectivity from the application VM to PostgreSQL port 5432.

**Still pending:** Successful database authentication and execution of a test SQL query.

## Milestone 6 — Static Retail Storefront

**Status: Previously deployed**

- Created the static retail storefront using HTML and CSS.
- Published the storefront using Azure Static Web Apps.
- Connected the GitHub repository to the deployment workflow.

The storefront is hosted independently of the Terraform-managed virtual network. Its deployment does not mean the backend application or database is integrated.

## Milestone 7 — CI/CD Verification

**Status: Previously tested successfully**

- Committed and pushed storefront changes to GitHub.
- Verified the GitHub Actions deployment workflow.
- Confirmed that updated content appeared on the live website.

## Milestone 8 — VM SKU and Quota Troubleshooting

**Status: Resolved for the deployed VMs**

- Investigated VM deployment failures caused by regional SKU availability and subscription quota restrictions.
- Used Azure CLI to inspect VM SKU restrictions and vCPU quotas.
- Selected `Standard_B2ats_v2`.
- Successfully deployed both South India VMs.

## Milestone 9 — Cost Management

**Status: Compute stopped after testing**

- Deallocated the web VM.
- Deallocated the application VM.
- Stopped the PostgreSQL Flexible Server.
- Confirmed that the VMs were deallocated and PostgreSQL was stopped.

Stopping compute does not eliminate all costs. Storage, backups, DNS, networking, and other retained resources may continue to incur charges. PostgreSQL may automatically restart after its permitted stopped period.

## Milestone 10 — Terraform and GitHub Reconciliation

**Status: Completed**

- Corrected the Terraform PostgreSQL server availability zone to match the deployed configuration.
- Added the `Microsoft.Storage` service endpoint to the PostgreSQL subnet configuration to match the deployed subnet.
- Ran `terraform fmt` and `terraform validate`.
- Confirmed `terraform plan` reported: `No changes. Your infrastructure matches the configuration.`
- Staged only `terraform-southindia/main.tf` and `terraform-southindia/variables.tf`.
- Confirmed Terraform state files and `.terraform/` are ignored by Git.
- Committed and pushed the changes; the working tree was clean afterward.

A no-change Terraform plan confirms Terraform sees no configuration changes to apply. It does not prove application connectivity or database authentication.

## Next Milestones

1. Start the VMs and run a simple test service on the application VM's TCP port 8080.
2. Test Web VM → App VM connectivity and record the actual result.
3. Securely authenticate to PostgreSQL and execute a test SQL query.
4. Deploy the application service and connect it to PostgreSQL.
5. Configure and validate Application Gateway if required.
6. Implement monitoring, backups, and resilience testing.
7. Review security rules and ongoing Azure costs.

## Project Notes

- The primary VM and network configuration is maintained in `terraform-southindia/`.
- The web and application VMs are in South India; PostgreSQL is in UK South.
- The Application Gateway subnet exists, but no Application Gateway has been deployed.
- The current Terraform configuration does not define a separate NSG for the PostgreSQL subnet.
- Nginx local testing, App-to-Web HTTP connectivity, PostgreSQL DNS resolution, and PostgreSQL TCP connectivity passed.
- Web-to-App application connectivity, PostgreSQL authentication, SQL execution, and full application integration remain unverified.
- Both VMs are deallocated and PostgreSQL is stopped; retained resources may still incur charges.
- The complete three-tier application and its high-availability mechanisms have not yet been implemented or verified.