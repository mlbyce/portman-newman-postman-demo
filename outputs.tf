# Output value definitions

output "base_url" {
  description = "Base URL for API Gateway stage."

  value = aws_api_gateway_stage.lambda.invoke_url
}

output "user_pool_id" {
  description = "User Pool ID"

  value = aws_cognito_user_pool.pool.id
}

output "user_pool_client_id" {
  description = "User Pool Client ID"

  value = aws_cognito_user_pool_client.client.id
}

output "api_key" {
  description = "API Key"
  value       = aws_api_gateway_api_key.apikey.value
  sensitive   = true
}