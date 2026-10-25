# Project Progress — Azure Three-Tier Retail Platform

**Last updated:** 25 October 2026

## Project Goal

Build and validate a secure, maintainable retail platform on Azure using a three-tier architecture:

1. **Presentation:** Retail storefront and web-serving layer.
2. **Application:** Application workload and business logic.
3. **Data:** PostgreSQL persistence layer.

The project also covers Terraform, network segmentation, private connectivity, managed identity, Key Vault, CI/CD, troubleshooting, and operational cost management.

## Status Summary

- **Infrastructure:** Core resources deployed.
- **Web validation:** Nginx HTTP response verified.
- **Application integration:** Incomplete; TCP 8080 application service and web-to-app request flow remain unverified.
- **Database networking:** Private DNS resolution and TCP connectivity verified; authentication and SQL execution pending.
- **Key Vault:** Managed-identity secret retrieval verified; retail application integration pending.
- **High availability:** Not yet implemented end to end.

## Milestones

### 1. Repository and Terraform foundation

**Status: Completed for the documented deployment**

- Established the GitHub repository and project structure.
- Maintained Terraform configuration for the Azure environment.
- Used Terraform to deploy and reconcile infrastructure.
- Retained an earlier `terraform/` directory alongside the current `terraform-southindia/` configuration.

**Operational note:** Confirm the intended directory and Terraform state before planning or applying changes.

### 2. South India virtual network and compute

**Status: Deployed**

- Created virtual network `ha-retail-vnet` with address space `10.0.0.0/16`.
- Created web subnet `10.0.2.0/24`.
- Created application subnet `10.0.3.0/24`.
- Reserved subnet `10.0.1.0/24` for a potential Application Gateway.
- Deployed Ubuntu 22.04 web and application VMs.
- Configured the VMs without public IP addresses and with SSH key authentication.

| Resource | Name | Private IP |
|---|---|---|
| Web VM | `ha-retail-southindia-web-vm` | `10.0.2.4` |
| Application VM | `ha-retail-southindia-app-vm` | `10.0.3.4` |

### 3. Web-tier HTTP validation

**Status: Completed for local web-server check**

- Installed or configured Nginx on the web VM.
- Verified an HTTP 200 response from Nginx on the web VM.

This confirms that the tested web server responded successfully. It does not prove that the complete storefront-to-application request path works.

### 4. Web-to-application integration

**Status: Pending**

- Configured the application NSG to allow inbound TCP 8080 from the web subnet `10.0.2.0/24`.
- Verified that an HTTP request from the application VM to the web VM returned HTTP 200.

**Important:** The successful test was in the application-to-web direction. The intended web-to-application direction has not yet been verified, and an application service listening on TCP 8080 has not been confirmed.

**Next action:** Verify the application service, test TCP 8080 from the web VM, and perform an HTTP request against the application endpoint.

### 5. PostgreSQL deployment and private networking

**Status: Infrastructure and network checks completed; database test pending**

- Deployed Azure Database for PostgreSQL Flexible Server in UK South.
- Configured public access as disabled.
- Used a delegated database subnet in a separate virtual network.
- Configured South India ↔ UK South VNet peering.
- Configured private DNS links for the network environments.

| Property | Value |
|---|---|
| Server | `ha-retail-southindia-pg` |
| Resource group | `ha-retail-southindia-postgresql-uksouth` |
| Region | UK South |
| PostgreSQL version | 18 |
| Database network | `10.1.0.0/16` |
| Database subnet | `10.1.1.0/24` |
| Private IP observed | `10.1.1.4` |

**Verified:**
- The database hostname resolved to the private IP from the application environment.
- TCP port 5432 was reachable from the application environment.

**Pending:**
- Authenticate to PostgreSQL from the application environment.
- Execute a test SQL query.
- Verify application-level database connectivity.

Network reachability alone does not confirm successful database authentication or query execution.

### 6. Retail storefront hosting

**Status: Deployed**

- Maintained storefront source code in `website/`.
- Hosted the storefront on Azure Static Web Apps.
- Used GitHub Actions for the storefront delivery workflow.

The hosted storefront and the separate web VM represent related presentation components; their complete integration with the application tier remains to be validated.

### 7. GitHub Actions and delivery workflow

**Status: Existing workflow verified**

- Maintained workflow definitions under `.github/workflows/`.
- Used GitHub for source control and automated storefront delivery.
- Kept infrastructure changes reviewable through repository commits.

Further automation and end-to-end validation can be added as the application becomes operational.

### 8. VM sizing and quota troubleshooting

**Status: Troubleshooting completed for the deployment steps performed**

- Worked through Azure VM sizing and quota constraints during deployment.
- Selected the VM sizes used by the current environment.

Current VMs use the `Standard_B2ats_v2` size. Recheck regional availability and quota before recreating or expanding the environment.

### 9. Operational cost management

**Status: Practices identified; ongoing monitoring required**

- Identified VM and database compute as resources to manage when the environment is not being tested.
- Established the need to check actual resource states before assuming that workloads are stopped.
- Recognized that deallocated VMs may still incur disk and other charges, and stopped PostgreSQL may still incur storage charges.

Before ending a testing session, verify which resources are running and stop or deallocate eligible resources when appropriate.

### 10. Terraform reconciliation and Key Vault deployment

**Status: Completed for the documented deployment**

- Reconciled Terraform configuration with the deployed environment.
- Deployed the Key Vault resources through Terraform.
- Recorded the deployment result: `Apply complete! Resources: 2 added, 1 changed, 0 destroyed.`

### 11. Key Vault network and identity configuration

**Status: Verified**

- Key Vault: `hrkv6952055559284c2ca73a`
- Resource group: `ha-retail-southindia`
- Configured Azure RBAC authorization.
- Assigned the application VM's system-assigned managed identity the `Key Vault Secrets User` role at vault scope.
- Enabled the `Microsoft.KeyVault` service endpoint on the application subnet.
- Restricted vault network access with firewall default action `Deny` and a virtual network rule for the application subnet.
- Kept the public endpoint protected by firewall rules; a Private Endpoint was not deployed.

### 12. Key Vault secret retrieval and permission cleanup

**Status: Completed and verified on 25 October 2026**

- Acquired a managed identity token from the application VM.
- Retrieved the `connectivity-test` secret from Key Vault.
- Received HTTP 200 and the result `SECRET_RETRIEVAL=SUCCESS`.
- Validated the expected test value without printing the secret value.
- Removed the temporary `Key Vault Secrets Officer` role assignment used during setup.
- Checked the subsequent role-assignment listing and confirmed that this temporary assignment was absent.

The remaining listing showed the inherited subscription `Owner` role and the application's `Key Vault Secrets User` role. The temporary Key Vault Secrets Officer assignment was no longer listed.

**Scope of validation:** This was a diagnostic test from the VM. The retail application has not yet been configured to consume the secret.

### 13. Current end-to-end integration status

**Status: In progress**

The infrastructure provides a foundation for the three-tier design, but the full application path has not yet been demonstrated.

| Test | Status |
|---|---|
| Nginx local HTTP response | Passed |
| App VM → web VM HTTP | HTTP 200 |
| Web VM → app VM TCP 8080 / HTTP | Pending |
| App environment → PostgreSQL DNS | Passed |
| App environment → PostgreSQL TCP 5432 | Passed |
| PostgreSQL authentication and SQL query | Pending |
| VM managed identity → Key Vault secret | Passed |
| Retail application → Key Vault | Pending |
| Full retail request flow | Pending |
| Application Gateway and high availability | Not implemented |

## Next Steps — Recommended Order

1. **Complete the application tier:** Verify or deploy the application service and confirm that TCP 8080 is listening.
2. **Validate web-to-application traffic:** Test the intended direction from the web VM to the application VM.
3. **Validate PostgreSQL credentials and SQL:** Run an authenticated database test from the application environment.
4. **Integrate Key Vault with the application:** Use the VM's managed identity and appropriate RBAC permissions; avoid logging secret values.
5. **Test the complete request path:** Demonstrate the storefront/web → application → database flow.
6. **Implement high availability:** Evaluate Application Gateway, backend redundancy, health probes, and failover behavior.
7. **Add monitoring and recovery procedures:** Define relevant alerts, backups, recovery expectations, and operational checks.
8. **Review security and cost:** Recheck role assignments, firewall rules, public exposure, running resources, and ongoing charges.

## Definition of Done

The project should not be described as a fully operational, highly available three-tier retail platform until:

- The intended web-to-application request succeeds.
- The application authenticates to PostgreSQL and executes a test query.
- The application retrieves the required secret through managed identity.
- A request is traced through the intended application path.
- High-availability components and failover behavior are implemented and tested if high availability is claimed.
- Documentation accurately reflects the final tested state.