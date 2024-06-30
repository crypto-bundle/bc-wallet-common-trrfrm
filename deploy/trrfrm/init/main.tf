provider "postgresql" {
  sslmode  = "disable"
  superuser = false
}

resource "random_password" "init_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

locals {
  k8s_init_service_account = "cryptobundle-bc-wallet-common-trrfrm-init"
  k8s_worker_service_account = "cryptobundle-bc-wallet-common-trrfrm-worker"

  trrfrm_database = "bc-wallet-common-trrfrm"

  trrfrm_init_username = "bc-wallet-common-trrfrm-init"
  trrfrm_init_password = random_password.init_password.result

  trrfrm_wrorker_username = "bc-wallet-common-trrfrm-worker"
  trrfrm_worker_password = random_password.password.result
}