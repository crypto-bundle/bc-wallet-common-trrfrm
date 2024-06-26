resource "vault_policy" "trrfrm_application_access_policy" {
  name = "trrfrm-app-policy"

  policy = <<EOT
path "kv/data/crypto-bundle/*" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}
EOT
}

resource "vault_policy" "trrfrm_transit_access_policy" {
  name = "trrfrm-transit-policy"

  policy = <<EOT
path "transit/+/crypto-bundle-*" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "hdwallet_application_auth_role" {
  backend                          = "kubernetes"
  role_name                        = local.k8s_service_account
  bound_service_account_names      = [
    local.k8s_service_account,
  ]
  bound_service_account_namespaces = [
    var.k8s_namespace,
  ]
  token_ttl                        = 3600
  token_policies                   = [
    vault_policy.trrfrm_application_access_policy.name,
    vault_policy.trrfrm_transit_access_policy.name,
  ]
  audience                         = ""
}

resource "vault_kv_secret_v2" "trrfrm_bucket" {
  mount                      = "kv"
  name                       = "crypto-bundle/bc-wallet-common/trrfrm"
  data_json                  = jsonencode(
    {
      POSTGRESQL_PASSWORD  = postgresql_role.trrfrm.password,
      POSTGRESQL_USERNAME  = postgresql_role.trrfrm.name
    }
  )
}