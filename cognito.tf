resource "aws_cognito_user_pool" "pool" {
  name = "contractTestPool-${local.uniq_stage}"
}

resource "aws_cognito_user_pool_client" "client" {
  name                                 = "ctpClient-${local.uniq_stage}"
  allowed_oauth_flows_user_pool_client = true
  generate_secret                      = false
  allowed_oauth_scopes                 = ["aws.cognito.signin.user.admin", "email", "openid", "profile"]
  allowed_oauth_flows                  = ["implicit", "code"]
  explicit_auth_flows                  = ["ADMIN_NO_SRP_AUTH", "USER_PASSWORD_AUTH"]
  supported_identity_providers         = ["COGNITO"]


  user_pool_id  = aws_cognito_user_pool.pool.id
  callback_urls = ["https://example.com"]
}
