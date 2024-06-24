resource "postgresql_role" "trrfrm" {
  name     = local.trrfrm_username
  login    = true
  password = local.trrfrm_password
}

resource "postgresql_database" "trrfrm-db" {
  name              = local.trrfrm_database
  owner             = postgresql_role.trrfrm.name
  connection_limit  = -1
  allow_connections = true
}