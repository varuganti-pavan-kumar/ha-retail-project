# HA Retail — Azure Infrastructure & DevOps Project

A hands-on cloud engineering portfolio project demonstrating Azure networking, infrastructure as code, CI/CD, Linux administration, and cloud troubleshooting.

## Project Overview

The goal is to build a secure, highly available retail application architecture on Microsoft Azure, using Terraform to provision infrastructure and GitHub Actions to automate website deployment.

**Current status:** Core networking and storefront deployment are complete. A temporary Linux VM and Nginx were successfully tested and then removed to control costs. The full three-tier architecture is still in progress.

## Architecture

The planned architecture separates the workload into distinct network tiers:

- **Web tier:** Receives web traffic.
- **Application tier:** Handles application logic.
- **Database tier:** Stores application data.
- **Application Gateway:** Intended to provide traffic routing and load balancing.

The static storefront is hosted separately through Azure Static Web Apps.

## Technologies Used

- Microsoft Azure
- Terraform
- Azure CLI
- Azure Virtual Network and Network Security Groups
- Azure Static Web Apps
- GitHub and GitHub Actions
- Ubuntu Linux and Nginx
- PowerShell

## Completed Work

### 1. Infrastructure as Code

- Configured Terraform and the AzureRM provider.
- Created resource groups, a virtual network, and dedicated subnets.
- Defined network security groups and inbound security rules.
- Stored Terraform configurations in GitHub.

### 2. Network Security

- Created separate web, application, and database network segments.
- Configured inbound rules for HTTPS, application traffic on TCP 8080, and PostgreSQL on TCP 5432.
- Added inbound deny rules for other traffic within the configured source scope.
- End-to-end application connectivity testing remains pending.

### 3. Static Storefront and CI/CD

- Built a retail storefront using HTML and CSS.
- Deployed it using Azure Static Web Apps.
- Connected the GitHub repository to GitHub Actions.
- Verified successful automated deployments.

### 4. Linux VM and Web Server Validation

- Investigated Azure VM SKU restrictions and regional availability.
- Successfully deployed an Ubuntu VM in South India using Terraform.
- Used Azure Run Command to administer the VM without opening inbound SSH access.
- Installed and enabled Nginx.
- Verified a successful local HTTP response (`HTTP/1.1 200 OK`).
- Destroyed the temporary VM environment after testing to control costs.

## Key Learning

A major troubleshooting lesson was that available vCPU quota does not guarantee that a particular VM SKU can be deployed. Regional capacity and subscription-specific restrictions must also be investigated.

The project also demonstrates the Terraform workflow: initialize, validate, plan, apply, verify, and destroy.

## Current Limitations

- The application and database tiers have not yet been deployed.
- Communication between all three tiers has not been tested.
- Application Gateway, load balancing, monitoring, backup, and resilience testing remain planned work.
- The Nginx test verified the response inside the VM; public access was not tested.
- High availability has not yet been implemented or demonstrated.

## Next Steps

1. Complete the application tier.
2. Deploy and configure the database tier.
3. Test permitted traffic between tiers.
4. Configure Application Gateway and load balancing.
5. Add monitoring and resilience testing.
6. Document deployment and cleanup procedures.

## Repository Structure

- `terraform/` — Original UK South Terraform configuration.
- `terraform-southindia/` — Separate Terraform configuration used for VM testing.
- `website/` — Static storefront source.
- `docs/PROGRESS.md` — Development log and troubleshooting notes.
- `.github/workflows/` — GitHub Actions workflow.

## Cost Awareness

Temporary South India resources were destroyed after testing. Terraform configuration files remain available for future redeployment. The original UK South resources and Static Web App remain deployed, so review Azure resources and costs regularly.

---

**Project status:** In progress — Azure Cloud Engineering portfolio project.