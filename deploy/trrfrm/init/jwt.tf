resource "jwt_hashed_token" "cryptobundle-main-token" {
  algorithm= "HS256"
  secret = random_password.cryptobundle-main-jwt-secret.result
  claims_json = jsonencode(
    {
      installment_uuid  = random_uuid.cryptobundle-installment-uuid.result
      expired_at = formatdate("YYYY-MM-DD hh:mm:ss", time_rotating.cryptobundle-jwt-expires-at.rotation_rfc3339)
      customer_name = var.customer_name
    }
  )
}