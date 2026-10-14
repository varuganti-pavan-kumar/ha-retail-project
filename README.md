# High-Availability Retail Platform on Azure

## Project Overview

This project explores how to design and build a secure, resilient online retail platform on Microsoft Azure using Terraform.

The long-term goal is to develop a three-tier architecture with separate web, application, and database layers, private networking, and appropriate high-availability and recovery mechanisms.

## Current Progress

### Milestone 1 — Terraform Foundation
- Created a structured Terraform project.
- Configured the AzureRM provider.
- Defined variables for the Azure region, project name, and environment.
- Added `.gitignore` rules to help keep Terraform state and local configuration out of Git.
- Committed and pushed the foundation to GitHub.

### Milestone 2 — First Azure Deployment
- Created the `ha-retail` Azure resource group using Terraform.
- Region: UK South (`uksouth`).
- Ran `terraform validate` successfully.
- Reviewed the Terraform plan before applying it.
- Verified the resource group's provisioning state using Azure CLI.

## Planned Architecture

- Public entry point using Azure Application Gateway.
- Private web tier using Virtual Machine Scale Sets.
- Application tier behind an internal load balancer.
- Private PostgreSQL database hosted on an Azure virtual machine.
- Network security rules restricting access between tiers.
- Future investigation of availability, backups, monitoring, and recovery testing.

## Tools

- Microsoft Azure
- Terraform
- Azure CLI
- Git and GitHub
- PowerShell

## Current Status

The Terraform foundation and initial resource group are deployed. The application tiers, database, networking, and high-availability mechanisms have not yet been implemented or tested.

This is an evolving learning and portfolio project. Architecture decisions, security controls, costs, and resilience will be assessed as implementation progresses.