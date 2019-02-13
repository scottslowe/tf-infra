---
# This file was created by the terraform backups module. 
apiVersion: v1
type: Opaque
kind: Secret
metadata:
  name: cloud-credentials
  namespace: heptio-ark
data:
  AZURE_CLIENT_ID: ${AZURE_CLIENT_ID}
  AZURE_CLIENT_SECRET: ${AZURE_CLIENT_SECRET}
  AZURE_RESOURCE_GROUP: ${AZURE_RESOURCE_GROUP}
  AZURE_SUBSCRIPTION_ID: ${AZURE_SUBSCRIPTION_ID}
  AZURE_TENANT_ID: ${AZURE_TENANT_ID}
