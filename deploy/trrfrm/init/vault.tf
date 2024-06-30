resource "vault_policy" "trrfrm_init_access_policy" {
  name = "cryptobundle-trrfrm-init-policy"

  policy = <<EOT
path "kv/data/crypto-bundle/*" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}
path "kv/metadata/crypto-bundle/*" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}
EOT
}

resource "vault_policy" "trrfrm_application_access_policy" {
  name = "cryptobundle-trrfrm-app-policy"

  policy = <<EOT
path "kv/data/crypto-bundle/*" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}

path "kv/data/crypto-bundle/bc-wallet-common/trrfmr/init" {
  capabilities = ["deny"]
}
EOT
}

resource "vault_policy" "trrfrm_transit_access_policy" {
  name = "cryptobundle-trrfrm-transit-policy"

  policy = <<EOT
path "transit/+/crypto-bundle-*" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}
EOT
}

resource "vault_policy" "trrfrm_policies_access_policy" {
  name = "cryptobundle-trrfrm-policies-policy"

  policy = <<EOT
path "/sys/policies/acl/cryptobundle-*" {
  capabilities = ["create", "read", "update", "patch", "delete"]
}

EOT
}

resource "vault_policy" "trrfrm_k8s_access_policy" {
  name = "cryptobundle-trrfrm-k8s-access-policy"

  policy = <<EOT
path "auth/kubernetes/role/cryptobundle-*" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}

path "auth/token/*" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "trrfrm_init_auth_role" {
  backend                          = "kubernetes"
  role_name                        = local.k8s_init_service_account
  bound_service_account_names      = [
    local.k8s_init_service_account,
  ]
  bound_service_account_namespaces = [
    var.k8s_namespace,
  ]
  token_ttl                        = 3600
  token_policies                   = [
    "default",
    vault_policy.trrfrm_init_access_policy.name,
    vault_policy.trrfrm_policies_access_policy.name,
    vault_policy.trrfrm_transit_access_policy.name,
    vault_policy.trrfrm_k8s_access_policy.name
  ]
  audience                         = ""
}

resource "vault_kubernetes_auth_backend_role" "trrfrm_worker_auth_role" {
  backend                          = "kubernetes"
  role_name                        = local.k8s_worker_service_account
  bound_service_account_names      = [
    local.k8s_worker_service_account,
  ]
  bound_service_account_namespaces = [
    var.k8s_namespace,
  ]
  token_ttl                        = 3600
  token_policies                   = [
    "default",
    vault_policy.trrfrm_init_access_policy.name,
    vault_policy.trrfrm_policies_access_policy.name,
    vault_policy.trrfrm_transit_access_policy.name,
    vault_policy.trrfrm_k8s_access_policy.name
  ]
  audience                         = ""
}

resource "vault_kv_secret_v2" "trrfrm_worker_bucket" {
  mount                      = "kv"
  name                       = "crypto-bundle/bc-wallet-common/trrfrm/worker"
  data_json                  = jsonencode(
    {
      POSTGRESQL_PASSWORD  = postgresql_role.trrfrm.password,
      POSTGRESQL_USERNAME  = postgresql_role.trrfrm.name
    }
  )
}