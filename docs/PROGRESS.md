# Project Development Log

This file tracks completed milestones, implementation progress, troubleshooting, validation results, and remaining work for the HA Retail Azure project.

**Last updated:** 2026-10-21
**Overall status:** Infrastructure deployed; Key Vault endpoint access validated; end-to-end application validation in progress.

## Milestone 1 — Terraform Foundation

**Status: Completed**

- Configured the Terraform Azure provider and version constraints.
- Added project variables and `.gitignore` rules.
- Ran Terraform formatting, validation, and planning.
- Created a separate Terraform configuration in `terraform-southindia/` for the South India infrastructure.
- Updated the Terraform source to match the deployed resources, including the PostgreSQL availability zone and subnet service endpoint configuration.
- Confirmed `terraform validate` succeeds and `terraform plan` reports no changes after the earlier reconciliation.
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

**Status: Compute was stopped after earlier testing; resources restarted for subsequent validation**

- Previously deallocated the web VM.
- Previously deallocated the application VM.
- Previously stopped the PostgreSQL Flexible Server.
- Confirmed that the VMs were deallocated and PostgreSQL was stopped at that time.
- Restarted the VMs and PostgreSQL for later validation work.

Stopping compute does not eliminate all costs. Storage, backups, DNS, networking, Key Vault, and other retained resources may continue to incur charges. PostgreSQL may automatically restart after its permitted stopped period.

Check current resource status and stop compute when testing is complete.

## Milestone 10 — Terraform and GitHub Reconciliation

**Status: Completed for the earlier reconciliation**

- Corrected the Terraform PostgreSQL server availability zone to match the deployed configuration.
- Added the `Microsoft.Storage` service endpoint to the PostgreSQL subnet configuration to match the deployed subnet.
- Ran `terraform fmt` and `terraform validate`.
- Confirmed `terraform plan` reported: `No changes. Your infrastructure matches the configuration.`
- Staged only the intended Terraform source files.
- Confirmed Terraform state files and `.terraform/` are ignored by Git.
- Committed and pushed the changes; the working tree was clean afterward.

The later Key Vault infrastructure changes were also formatted, validated, planned, and applied successfully. The Key Vault deployment reported `2 added, 1 changed, 0 destroyed`.

A no-change Terraform plan confirms Terraform sees no configuration changes to apply. It does not prove application connectivity or database authentication.

## Milestone 11 — Azure Key Vault and Managed Identity

**Status: Deployed; endpoint access test passed; actual secret retrieval pending**

- Created Azure Key Vault `hrkv6952055559284c2ca73a` in South India using Terraform.
- Enabled Key Vault RBAC authorization.
- Configured the vault's network ACL default action as `Deny`.
- Enabled the `Microsoft.KeyVault` service endpoint on the application subnet.
- Added the application subnet to the Key Vault's virtual network rules.
- Enabled soft delete with a seven-day retention period and enabled purge protection.
- Enabled the application VM's system-assigned managed identity.
- Assigned the `Key Vault Secrets User` role to the application VM identity at the individual vault scope.
- Verified that the vault reports RBAC enabled, public network access enabled, and a default network action of `Deny`.
- Verified that the expected role assignment exists for the application VM's managed identity.
- Used Azure Run Command to test the application VM's managed identity and Key Vault endpoint.
- Confirmed `MANAGED_IDENTITY_TOKEN_ACQUIRED=True`.
- Confirmed `KEY_VAULT_HTTP_STATUS=200`.

**Important distinction:** The HTTP 200 result verifies authenticated access to the secrets endpoint. A separate secret-list request using the developer's Azure CLI identity returned `403 ForbiddenByRbac` because that identity does not have the necessary Key Vault data-plane permission. This is distinct from the app VM's managed identity.

**Still pending:**

- Create a harmless test secret using an appropriately authorized identity.
- Verify that the app VM can retrieve that secret.
- Confirm the secret value is not printed or logged.
- Integrate Key Vault into the application configuration.

## Next Milestones

1. Verify actual secret retrieval from the app VM using a non-sensitive test secret.
2. Start or confirm the VMs are running and run a simple test service on the application VM's TCP port 8080.
3. Test Web VM → App VM connectivity and record the actual result.
4. Securely authenticate to PostgreSQL and execute a test SQL query.
5. Deploy the application service and connect it to PostgreSQL and Key Vault.
6. Configure and validate Application Gateway if required.
7. Implement monitoring, backups, and resilience testing.
8. Review security rules and ongoing Azure costs.

## Project Notes

- The primary VM and network configuration is maintained in `terraform-southindia/`.
- The web and application VMs are in South India; PostgreSQL is in UK South.
- The Application Gateway subnet exists, but no Application Gateway has been deployed.
- The current Terraform configuration does not define a separate NSG for the PostgreSQL subnet.
- Nginx local testing, App-to-Web HTTP connectivity, PostgreSQL DNS resolution, and PostgreSQL TCP connectivity passed.
- Key Vault managed-identity token acquisition and authenticated secrets-endpoint access passed.
- Actual Key Vault secret retrieval, Web-to-App application connectivity, PostgreSQL authentication, SQL execution, and full application integration remain unverified.
- Check the current status of the VMs and PostgreSQL before assuming they are stopped. Retained resources may still incur charges.
- The complete three-tier application and its high-availability mechanisms have not yet been implemented or verified.
