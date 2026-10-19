# Project Development Log

This file tracks completed milestones, implementation decisions, troubleshooting, and verification results for the HA Retail Azure project.

## Milestone 1 — Terraform Foundation

**Status:** Completed

- Configured the Terraform Azure provider and version constraints.
- Added project variables and `.gitignore` rules.
- Ran Terraform formatting, validation, and planning.

## Milestone 2 — Azure Network Foundation

**Status:** Completed

- Created the `ha-retail` resource group in UK South.
- Deployed a virtual network with address space `10.0.0.0/16`.
- Created dedicated subnets for Application Gateway, web, application, and database tiers.
- Verified deployed network resources using Azure CLI.

## Milestone 3 — Network Security

**Status:** Implemented; end-to-end connectivity testing pending

- Associated network security groups with the web, application, and database subnets.
- Configured inbound rules for HTTPS, application traffic on TCP 8080, and PostgreSQL on TCP 5432.
- Added inbound deny rules for other traffic matching the configured virtual-network source scope.
- Verified configured rules using Azure CLI.

## Milestone 4 — Static Storefront

**Status:** Completed

- Created a static retail storefront using HTML and CSS.
- Published it using Azure Static Web Apps.
- Connected the GitHub repository to automated deployment.

## Milestone 5 — CI/CD Verification

**Status:** Tested successfully

- Committed and pushed storefront changes to GitHub.
- Verified the GitHub Actions deployment workflow.
- Confirmed updated content appeared on the live website.

## Milestone 6 — VM Deployment Troubleshooting

**Status:** Investigated; resolved by changing region

- Encountered VM deployment failures in UK South due to SKU capacity and subscription availability restrictions.
- Tested alternative VM sizes, including `Standard_B1s` and `Standard_B2ats_v2`.
- Used Azure CLI to inspect regional SKU restrictions and VM quota.
- Investigated East US 2 and found similar subscription restrictions for the VM sizes checked.
- Confirmed that available vCPU quota does not guarantee availability of a particular VM SKU.
- Evaluated South India and created a separate Terraform configuration and resource group.

## Milestone 7 — South India VM and Web Server Validation

**Status:** Successful

- Validated the separate Terraform configuration and reviewed a plan for 14 resources.
- Successfully deployed 14 Azure resources.
- Verified that the Ubuntu Linux VM was running.
- Executed remote commands using Azure Run Command without opening inbound SSH access.
- Installed Nginx and enabled it to start automatically.
- Tested Nginx using `curl -I http://localhost`.
- Received `HTTP/1.1 200 OK`, confirming that Nginx responded successfully inside the VM.

## Next Milestones

- Deploy and test the application tier.
- Deploy and configure the database tier.
- Verify communication between the web, application, and database tiers.
- Configure Application Gateway and load balancing.
- Implement monitoring, backup, and resilience testing.

## Project Notes

- The static storefront is hosted independently of the Terraform-managed virtual network.
- The VM and Nginx test confirms local web-server functionality; public access has not been tested.
- The complete three-tier application and its high-availability mechanisms have not yet been deployed.
- The South India infrastructure is managed through a separate Terraform configuration in `terraform-southindia`.
- VM SKU availability varies by region and subscription.