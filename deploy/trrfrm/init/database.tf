resource "postgresql_role" "trrfrm" {
  name     = local.trrfrm_wrorker_username
  login    = true
  password = local.trrfrm_worker_password

  superuser = false
}

resource "postgresql_role" "trrfrm2" {
  name     = "bc-wallet-common-trrfrm-worker-22"
  login    = true
  password = local.trrfrm_worker_password

  superuser = false
}


resource "postgresql_grant" "worker_user_connect" {
  database    = "bc-wallet-common-trrfrm"
  role        = postgresql_role.trrfrm.name
  object_type = "database"
  privileges  = ["CONNECT"]
}

resource "postgresql_grant" "worker_user_grants" {
  database    = "bc-wallet-common-trrfrm"
  role        = postgresql_role.trrfrm.name
  schema      = "bc-wallet-common-trrfrm"
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
}

resource "postgresql_grant" "worker_user_usage" {
  database    = "bc-wallet-common-trrfrm"
  role        = postgresql_role.trrfrm.name
  schema      = "bc-wallet-common-trrfrm"
  object_type = "schema"
  privileges  = ["USAGE"]
}

resource "postgresql_grant" "worker_user_public_usage" {
  database    = "bc-wallet-common-trrfrm"
  role        = postgresql_role.trrfrm.name
  schema      = "public"
  object_type = "schema"
  privileges  = ["USAGE"]
}

resource "postgresql_grant" "worker_user_public_sequence_usage" {
  database    = "bc-wallet-common-trrfrm"
  role        = postgresql_role.trrfrm.name
  schema      = "public"
  object_type = "sequence"
  privileges  = ["USAGE", "SELECT", "UPDATE"]
}


resource "postgresql_schema" "init_user_schema" {
  database = "bc-wallet-common-trrfrm"
  name  = "bc-wallet-common-trrfrm"
  owner = local.trrfrm_init_username
  if_not_exists = true
}