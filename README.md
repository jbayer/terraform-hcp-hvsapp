# HCP Vault Secrets App with read-only Service Principal

This module provisions an HVS application and an associated
 HCP Service Principal with viewer permissions for the project.

Secrets for this application should be added separately in the 
 HCP Portal, CLI, or API.

The resulting client id and client secret can be used to read
the secrets for this application with least priviledge.

The HCP Service Principal key will be rotated once the key
 is 30 days old or more.