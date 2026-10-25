# Project Progress — Azure Three-Tier Retail Platform

**Last updated:** 25 October 2026

## Project Goal

Build and validate a secure, maintainable retail platform on Azure using three logical tiers:

1. **Presentation:** Retail storefront and web-serving layer.
2. **Application:** API and business logic.
3. **Data:** PostgreSQL persistence layer.

The project also covers Terraform, network segmentation, private connectivity, managed identity, Key Vault, CI/CD, troubleshooting, and cost management.

## Status Summary

- **Infrastructure:** Core Azure resources deployed.
- **Web tier:** Nginx HTTP response verified.
- **Application tier:** Python demo API running on TCP 8080.
- **Web-to-application connectivity:** HTTP request successfully tested from the web VM.
- **Database networking:** Private DNS resolution and TCP 5432 connectivity verified.
- **Database authentication:** `retailapp` login and test table create/drop operation succeeded.
- **Key Vault:** Managed-identity secret retrieval verified.
- **Security cleanup:** Temporary Key Vault role assignment and IP firewall rule removed and checked.
- **PostgreSQL administrator password:** Reset after temporary credential handling.
- **Application integration:** API still returns hardcoded demo products and is not yet connected to PostgreSQL.
- **High availability:** Not implemented end to end.

## Milestones

### 1. Repository and Terraform Foundation

**Status: Completed for the documented deployment**

- Established the GitHub repository and project structure.
- Maintained Terraform configuration for the Azure environment.
- Used Terraform to deploy and reconcile infrastructure.
- Retained an earlier `terraform/` directory alongside the current `terraform-southindia/` configuration.

**Operational note:** Confirm the intended directory and Terraform state before planning or applying changes.

### 2. South India Virtual Network and Compute

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

### 3. Web-Tier HTTP Validation

**Status: Completed for the local web-server check**

- Configured Nginx on the web VM.
- Verified an HTTP 200 response from Nginx on the web VM.

This confirms the tested web server responded successfully. The full storefront-to-database request flow remains incomplete.

### 4. Application API Deployment

**Status: Deployed and tested on the VM**

- Created the application directory `/opt/ha-retail-api/`.
- Deployed a Python demo API in `/opt/ha-retail-api/app.py`.
- Configured the `ha-retail-api.service` systemd service.
- Enabled the service to start automatically.
- Configured the API to listen on TCP 8080.
- Verified the `/health` endpoint returns a healthy status.
- Verified the `/api/products` endpoint returns demo product JSON.

**Current limitation:** The API returns hardcoded demo products. Its source and deployment instructions have not yet been committed to the repository, so deployment is not yet reproducible from GitHub alone.

### 5. Web-to-Application Integration

**Status: HTTP connectivity verified**

- Configured the application NSG to allow inbound TCP 8080 from web subnet `10.0.2.0/24`.
- Verified an HTTP request from the web VM to `http://10.0.3.4:8080/health`.
- Verified the application health endpoint returns a successful response.
- Verified the web VM can request `/api/products` and receive JSON.

The intended web-to-application network path is working.

**Remaining work:** Integrate the API with the retail frontend and database. The current API is a demo service, not a complete retail backend.

### 6. PostgreSQL Deployment and Private Networking

**Status: Deployed; network and login checks completed**

- Deployed Azure Database for PostgreSQL Flexible Server in UK South.
- Configured public access as disabled.
- Used a delegated database subnet in a separate virtual network.
- Configured South India ↔ UK South VNet peering.
- Configured private DNS for database hostname resolution.
- Created database `retaildb`.
- Created or updated the dedicated application login `retailapp`.

| Property | Value |
|---|---|
| Server | `ha-retail-southindia-pg` |
| Resource group | `ha-retail-southindia-postgresql-uksouth` |
| Region | UK South |
| PostgreSQL version | 18 |
| Database | `retaildb` |
| Database network | `10.1.0.0/16` |
| Database subnet | `10.1.1.0/24` |
| Private IP observed | `10.1.1.4` |
| Application login | `retailapp` |

**Verified:**

- Database hostname resolves to the private IP from the application environment.
- TCP port 5432 is reachable from the application environment.
- PostgreSQL authentication using `retailapp` succeeded.
- A test table was successfully created and dropped in the `app` schema.
- The test used the application database password retrieved from Key Vault.

**Security follow-up completed:** The PostgreSQL administrator password was reset after temporary credential handling during setup. The application login uses a separate password stored in Key Vault.

**Remaining work:** Connect the demo API to PostgreSQL and validate actual application data operations.

### 7. Retail Storefront Hosting

**Status: Deployed**

- Maintained storefront source code in `website/`.
- Hosted the storefront on Azure Static Web Apps.
- Used GitHub Actions for the existing storefront delivery workflow.

The hosted storefront and the separate Nginx web VM are related presentation components. Their complete integration with the API and database remains to be demonstrated.

### 8. GitHub Actions and Delivery Workflow

**Status: Existing workflow established**

- Maintained workflow definitions under `.github/workflows/`.
- Used GitHub for source control and automated storefront delivery.
- Kept infrastructure changes reviewable through repository commits.

**Remaining work:** Add reproducible deployment for the demo API and automated tests for the application and database integration.

### 9. VM Sizing and Quota Troubleshooting

**Status: Troubleshooting completed for the deployment steps performed**

- Worked through Azure VM sizing and quota constraints.
- Selected the VM sizes used by the current environment.

Current VMs use `Standard_B2ats_v2`. Recheck regional availability and quota before recreating or expanding the environment.

### 10. Operational Cost Management

**Status: Practices identified; ongoing monitoring required**

- Identified VM and database compute as resources to manage when the environment is not being tested.
- Established the need to verify actual resource states before assuming workloads are stopped.
- Recognized that deallocated VMs may still incur disk and other charges, and stopped PostgreSQL may still incur storage charges.

Before ending a testing session, verify which resources are running and stop or deallocate eligible resources when appropriate.

### 11. Terraform Reconciliation and Key Vault Deployment

**Status: Completed for the documented deployment**

- Reconciled Terraform configuration with the deployed environment.
- Deployed Key Vault resources through Terraform.
- Recorded the deployment result: `Apply complete! Resources: 2 added, 1 changed, 0 destroyed.`

### 12. Key Vault Network and Identity Configuration

**Status: Verified**

- Key Vault: `hrkv6952055559284c2ca73a`
- Resource group: `ha-retail-southindia`
- Configured Azure RBAC authorization.
- Assigned the application VM's system-assigned managed identity the `Key Vault Secrets User` role at vault scope.
- Enabled the `Microsoft.KeyVault` service endpoint on the application subnet.
- Restricted network access with firewall default action `Deny` and a virtual network rule for the application subnet.
- Kept the public endpoint protected by firewall rules; a Private Endpoint was not deployed.
- Verified that the vault has purge protection enabled.

### 13. Key Vault Secret Retrieval and Permission Cleanup

**Status: Completed and verified on 25 October 2026**

- Acquired a managed identity token from the application VM.
- Retrieved the `connectivity-test` secret from Key Vault.
- Received HTTP 200 and the result `SECRET_RETRIEVAL=SUCCESS`.
- Validated the expected test result without printing the secret value.
- Removed the temporary `Key Vault Secrets Officer` role assignment used during setup.
- Checked the subsequent role-assignment listing and confirmed that this temporary assignment was absent.
- Verified that the temporary IP firewall rule was removed.
- Verified the firewall default action is `Deny` and the IP rule list is empty.

The application's `Key Vault Secrets User` role remains necessary for secret retrieval. The temporary elevated role was removed.

**Scope of validation:** These tests establish identity-based secret retrieval from the VM. They do not establish that the retail API itself consumes Key Vault secrets.

### 14. Application Database Credential and Security Follow-Up

**Status: Application login verified; administrator password reset completed**

- Stored the dedicated application database password in Key Vault as `retailapp-db-password`.
- Configured the application VM to retrieve the application password through its managed identity.
- Used the retrieved password to authenticate as `retailapp`.
- Successfully created and dropped a test table in the `app` schema.
- Reset the PostgreSQL administrator password after temporary credential handling during provisioning.

**Remaining work:** Perform a clean identity-query verification and integrate actual database operations into the demo API.

No passwords or secret values should be committed to the repository or printed in application logs.

### 15. Current End-to-End Integration Status

**Status: Infrastructure and basic connectivity verified; retail application integration in progress**

| Test | Status |
|---|---|
| Nginx local HTTP response | Passed |
| App VM → web VM HTTP | HTTP 200 verified |
| Web VM → app VM HTTP | Demo API response verified |
| Application health endpoint | Passed |
| Application product endpoint | Demo product JSON returned |
| Application environment → PostgreSQL DNS | Passed |
| Application environment → PostgreSQL TCP 5432 | Passed |
| PostgreSQL authentication using `retailapp` | Passed |
| Test table create/drop | Passed |
| VM managed identity → Key Vault | Passed |
| Key Vault firewall default-deny | Verified |
| Temporary Key Vault elevated role cleanup | Verified |
| Temporary Key Vault IP rule cleanup | Verified |
| Retail API → PostgreSQL integration | Pending |
| Retail API → Key Vault integration | Pending |
| Full storefront-to-database request flow | Pending |
| Application Gateway and high availability | Not implemented |

## Next Steps — Recommended Order

1. **Make API deployment reproducible:** Commit the demo API source and deployment instructions.
2. **Integrate PostgreSQL:** Replace hardcoded product data with database-backed operations.
3. **Integrate Key Vault:** Retrieve application secrets using managed identity without printing their values.
4. **Test API database operations:** Verify reads and writes through the API using the dedicated application login.
5. **Complete the request flow:** Demonstrate the storefront/web → API → PostgreSQL path.
6. **Implement high availability:** Evaluate Application Gateway, backend redundancy, health probes, and failover behavior.
7. **Add monitoring and recovery procedures:** Define alerts, backups, recovery expectations, and operational checks.
8. **Review security and cost:** Recheck role assignments, firewall rules, public exposure, resource state, and ongoing charges.

## Definition of Done

The project should not be described as a fully operational, highly available three-tier retail platform until:

- The intended web-to-application request succeeds.
- The API reads and writes actual application data in PostgreSQL.
- Required secrets are retrieved through managed identity.
- A request is traced through the intended application path.
- Application deployment is reproducible from source control.
- High-availability components and failover behavior are implemented and tested before claiming high availability.
- Documentation accurately reflects the tested state.

## Conclusion

The project establishes a three-tier Azure architecture with separated web and application subnets, a privately networked cross-region PostgreSQL database, Terraform-managed infrastructure, and identity-based Key Vault access.

The demo API is running, web-to-application connectivity is verified, and PostgreSQL authentication and a database write test have succeeded.

The next major milestone is to connect the API to PostgreSQL and Key Vault, make application deployment reproducible, and implement and test the redundancy and recovery measures required for high availability.
