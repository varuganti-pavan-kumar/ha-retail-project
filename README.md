# High-Availability Retail Platform on Azure

## Project Overview

This project explores the design and implementation of a secure, resilient three-tier retail platform on Microsoft Azure using Terraform.

The planned architecture separates the web, application, and database tiers, with private networking, controlled traffic flow, and future high-availability and recovery testing.

## Current Progress

### Milestone 1 — Terraform Foundation
- Configured the AzureRM provider and Terraform variables.
- Added `.gitignore` rules to help prevent Terraform state and local configuration from being committed.
- Validated the Terraform configuration and pushed the foundation to GitHub.

### Milestone 2 — Resource Group Deployment
- Created the `ha-retail` resource group in UK South (`uksouth`) using Terraform.
- Verified the resource group using Azure CLI.

### Milestone 3 — Virtual Network and Subnets
- Deployed the `ha-retail-vnet` virtual network.
- Configured address space `10.0.0.0/16`.
- Created four subnets:
  - Application Gateway: `10.0.1.0/24`
  - Web tier: `10.0.2.0/24`
  - Application tier: `10.0.3.0/24`
  - Database tier: `10.0.4.0/24`
- Successfully ran Terraform formatting, validation, planning, and deployment.
- Independently verified the deployed subnets using Azure CLI.

## Planned Architecture

- Azure Application Gateway as the public entry point.
- Private web tier using Virtual Machine Scale Sets.
- Application tier behind an internal load balancer.
- Private PostgreSQL database hosted on an Azure virtual machine.
- Network security rules to restrict traffic between tiers.
- Future monitoring, backup, availability, and recovery testing.

## Tools and Technologies

- Microsoft Azure
- Terraform
- Azure CLI
- PowerShell
- Git and GitHub

## Current Status

The Terraform foundation, resource group, virtual network, and four subnets have been deployed and verified.

The Application Gateway, virtual machines, load balancer, database, network security rules, and high-availability mechanisms have not yet been deployed or tested.

This is an ongoing learning and portfolio project. Security, cost, and resilience will be evaluated as implementation progresses.
