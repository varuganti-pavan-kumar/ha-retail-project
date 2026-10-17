# HA Retail — Azure Cloud Engineering Portfolio Project

## Project Overview

This project demonstrates the foundations of a secure, resilient retail platform on Microsoft Azure. It uses Terraform for infrastructure as code, Azure networking for tier separation, and GitHub Actions to automate website deployment.

The project is being developed incrementally, with an emphasis on cloud engineering fundamentals, security, automation, and cost awareness.

## Live Demo

- **Hosting:** Azure Static Web Apps (Free plan)
- **Source code:** [GitHub Repository](https://github.com/varuganti-pavan-kumar/ha-retail-project)
- **Deployment:** GitHub Actions
- **Website source:** `website/index.html`

Changes pushed to the GitHub `main` branch automatically trigger the configured deployment workflow. A successful test confirmed that a committed website change appeared on the live site.

## Implemented Milestones

### 1. Terraform Foundation
- Configured the AzureRM provider and Terraform version constraints.
- Defined reusable project variables.
- Added `.gitignore` rules to help prevent Terraform state and local configuration files from being committed.
- Ran Terraform formatting, validation, and planning.

### 2. Azure Networking
- Created the `ha-retail` resource group in UK South (`uksouth`).
- Deployed the `ha-retail-vnet` virtual network with address space `10.0.0.0/16`.
- Created four subnets:

| Tier | Subnet | Address range |
|---|---|---|
| Application Gateway | `snet-appgateway` | `10.0.1.0/24` |
| Web | `snet-web` | `10.0.2.0/24` |
| Application | `snet-app` | `10.0.3.0/24` |
| Database | `snet-db` | `10.0.4.0/24` |

### 3. Network Security Groups
Deployed and associated network security groups with the web, application, and database subnets.

Configured inbound rules to allow:
- HTTPS (TCP 443) from the Application Gateway subnet to the web subnet.
- TCP 8080 from the web subnet to the application subnet.
- PostgreSQL (TCP 5432) from the application subnet to the database subnet.

Additional inbound rules deny other traffic matching the configured virtual-network source scope. These rules have been deployed and verified using Azure CLI; end-to-end application connectivity and comprehensive security testing remain future tasks.

### 4. Static Website and CI/CD
- Built a simple retail storefront using HTML and CSS.
- Published it through Azure Static Web Apps.
- Connected the GitHub repository to the deployment workflow.
- Tested automatic deployment by pushing a website change and verifying the live update.

**Architecture note:** The static storefront is currently hosted independently of the Terraform-managed virtual network. It is a working website and deployment demonstration, not yet the front end of the planned three-tier infrastructure.

## Planned Architecture

The next stages aim to develop a VM-based three-tier architecture:

- Azure Application Gateway as the public entry point.
- Web tier using Virtual Machine Scale Sets.
- Application tier behind an internal load balancer.
- PostgreSQL hosted on a private virtual machine.
- Monitoring, backup, availability, and recovery testing.

These components are planned and have not yet been deployed.

## Tools and Technologies

- Microsoft Azure
- Terraform
- Azure CLI
- PowerShell
- Git and GitHub
- GitHub Actions
- Azure Static Web Apps
- HTML and CSS

## Learning Objectives

- Provision cloud infrastructure using infrastructure as code.
- Apply network segmentation and inbound traffic controls.
- Build and verify automated deployment workflows.
- Understand the trade-offs between cost, security, availability, and resilience.
- Progress toward a demonstrable three-tier Azure architecture.

## Current Status

The Terraform networking foundation, subnet-level NSGs and inbound rules, and independently hosted static storefront have been deployed. Automatic website deployment has been tested successfully.

The virtual machines, Application Gateway, load balancer, PostgreSQL server, and high-availability mechanisms remain future milestones.

This is an ongoing learning and portfolio project.
