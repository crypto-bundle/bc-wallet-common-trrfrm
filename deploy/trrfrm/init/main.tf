resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

locals {
  k8s_service_account = "bc-wallet-common-trrfrm"

  trrfrm_database = "bc-wallet-common-trrfrm"
  trrfrm_username = "bc-wallet-common-trrfrm"
  trrfrm_password = random_password.password.result
}