---
# This file was created by the terraform backups module. 
apiVersion: ark.heptio.com/v1
kind: BackupStorageLocation
metadata:
  name: default
  namespace: heptio-ark
spec:
  provider: azure
  objectStorage:
    bucket: ${ark_blob_container_name}
  config:
    resourceGroup: ${ark_resource_group_name}
    storageAccount: ${ark_storage_account_name}