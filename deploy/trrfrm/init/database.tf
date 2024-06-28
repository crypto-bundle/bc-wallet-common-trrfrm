resource "postgresql_role" "trrfrm_init" {
  name     = local.trrfrm_init_username
  login    = true
  password = local.trrfrm_init_password
}

resource "postgresql_role" "trrfrm" {
  name     = local.trrfrm_wrorker_username
  login    = true
  password = local.trrfrm_worker_password
}

resource "postgresql_database" "trrfrm-db" {
  name              = local.trrfrm_database
  owner             = postgresql_role.trrfrm.name
  connection_limit  = -1
  allow_connections = true
}

resource "postgresql_grant" "init_user" {
  database    = "postgres"
  role        = postgresql_role.trrfrm_init.name
  schema      = "bc-wallet-common-trrfrm"
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
}

resource "postgresql_grant" "init_user_usage" {
  database    = "postgres"
  role        = postgresql_role.trrfrm_init.name
  schema      = "bc-wallet-common-trrfrm"
  object_type = "schema"
  privileges  = ["USAGE"]
}

resource "postgresql_grant" "init_user_public_usage" {
  database    = "postgres"
  role        = postgresql_role.trrfrm_init.name
  schema      = "public"
  object_type = "schema"
  privileges  = ["USAGE"]
}

resource "postgresql_schema" "init_user_schema" {
  name  = "bc-wallet-common-trrfrm"
  owner = postgresql_role.trrfrm_init.name
  if_not_exists = false
}

#resource "postgresql_grant" "init_user_connect" {
#  database    = "postgres"
#  role        = postgresql_role.trrfrm_init.name
#  object_type = "database"
#  privileges  = ["CONNECT"]
#}