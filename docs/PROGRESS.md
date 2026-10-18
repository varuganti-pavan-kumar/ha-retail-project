# Project Development Log

This file tracks completed milestones, implementation decisions, and verification results for the HA Retail Azure project.

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
- Verified the deployed network resources using Azure CLI.

## Milestone 3 — Network Security

**Status:** Implemented; end-to-end connectivity testing pending

- Associated network security groups with the web, application, and database subnets.
- Configured inbound rules for HTTPS, application traffic on TCP 8080, and PostgreSQL on TCP 5432.
- Added inbound deny rules for other traffic matching the configured virtual-network source scope.
- Verified the configured rules using Azure CLI.

## Milestone 4 — Static Storefront

**Status:** Completed

- Created a static retail storefront using HTML and CSS.
- Published it using Azure Static Web Apps.
- Connected the GitHub repository to automated deployment.

## Milestone 5 — CI/CD Verification

**Status:** Tested successfully

- Updated the storefront source code.
- Committed and pushed the change to GitHub.
- Verified the GitHub Actions deployment workflow.
- Confirmed the updated content appeared on the live website.

## Next Milestones

- Deploy and test the planned VM-based three-tier architecture.
- Configure the Application Gateway and load balancing.
- Deploy the application tier and private PostgreSQL server.
- Implement monitoring, backup, and resilience testing.

## Project Notes

The static storefront is currently hosted independently of the Terraform-managed virtual network. The complete three-tier application and its high-availability mechanisms have not yet been deployed.
