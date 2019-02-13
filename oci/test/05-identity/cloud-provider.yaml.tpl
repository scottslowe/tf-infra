auth:
  region: us-phoenix-1
  tenancy: ${tenancy_ocid}
  user: ${user_ocid}
  key: |
    ${auth_key}
  fingerprint: "DO_NOT_USE_WITHOUT_MANUALLY_SETTING_THIS_VALUE_FIRST"
  useInstancePrincipals: false
compartment: ${tenancy_ocid}
vcn: ${vcn_id}
loadBalancer:
  subnet1: ${lb_subnet1}
  subnet2: ${lb_subnet2}
  securityListManagementMode: Frontend
  # Optional specification of which security lists to modify per subnet. This does not apply if security list management is off.
  #securityLists:
  #  ocid1.subnet.oc1.phx.aaaaaaaasa53hlkzk6nzksqfccegk2qnkxmphkblst3riclzs4rhwg7rg57q: ocid1.securitylist.oc1.iad.aaaaaaaaqti5jsfvyw6ejahh7r4okb2xbtuiuguswhs746mtahn72r7adt7q
  #  ocid1.subnet.oc1.phx.aaaaaaaahuxrgvs65iwdz7ekwgg3l5gyah7ww5klkwjcso74u3e4i64hvtvq: ocid1.securitylist.oc1.iad.aaaaaaaaqti5jsfvyw6ejahh7r4okb2xbtuiuguswhs746mtahn72r7adt7q
# Optional rate limit controls for accessing OCI API
rateLimiter:
  rateLimitQPSRead: 20.0
  rateLimitBucketRead: 5
  rateLimitQPSWrite: 20.0
  rateLimitBucketWrite: 5
