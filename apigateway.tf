resource "aws_api_gateway_rest_api" "bogus_api" {
  name        = "bogus_api"
  description = "Bogus API Gateway"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_authorizer" "jwt" {
  name          = "bogus_api_jwt_auth"
  rest_api_id   = aws_api_gateway_rest_api.bogus_api.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = [aws_cognito_user_pool.pool.arn]
}

resource "aws_api_gateway_api_key" "apikey" {
  name = "bogus_api_key_auth"
}

resource "aws_api_gateway_usage_plan" "apikey" {
  name = "bogus_api_usage_plan"
  api_stages {
    api_id = aws_api_gateway_rest_api.bogus_api.id
    stage  = aws_api_gateway_stage.lambda.stage_name
  }

  quota_settings {
    limit  = 500
    offset = 1
    period = "WEEK"
  }

  throttle_settings {
    burst_limit = 20
    rate_limit  = 10
  }

  depends_on = [
    aws_api_gateway_deployment.deployment,
    aws_api_gateway_api_key.apikey
  ]
}

resource "aws_api_gateway_usage_plan_key" "apikey" {
  key_id        = aws_api_gateway_api_key.apikey.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.apikey.id
  depends_on = [
    aws_api_gateway_usage_plan.apikey,
    aws_api_gateway_api_key.apikey
  ]
}

# /user-by-id
resource "aws_api_gateway_resource" "userById_resource" {
  rest_api_id = aws_api_gateway_rest_api.bogus_api.id
  parent_id   = aws_api_gateway_rest_api.bogus_api.root_resource_id
  path_part   = "user-by-id"
}

resource "aws_api_gateway_method" "getUserById_method" {
  rest_api_id      = aws_api_gateway_rest_api.bogus_api.id
  resource_id      = aws_api_gateway_resource.userById_resource.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
  authorizer_id    = aws_api_gateway_api_key.apikey.id
}

resource "aws_api_gateway_integration" "getUserById_integration" {
  rest_api_id             = aws_api_gateway_rest_api.bogus_api.id
  resource_id             = aws_api_gateway_resource.userById_resource.id
  http_method             = aws_api_gateway_method.getUserById_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.getUserById.invoke_arn
}

# /user-by-jwt
resource "aws_api_gateway_resource" "userByJwt_resource" {
  rest_api_id = aws_api_gateway_rest_api.bogus_api.id
  parent_id   = aws_api_gateway_rest_api.bogus_api.root_resource_id
  path_part   = "user-by-jwt"
}

resource "aws_api_gateway_method" "getUserByJwt_method" {
  rest_api_id      = aws_api_gateway_rest_api.bogus_api.id
  resource_id      = aws_api_gateway_resource.userByJwt_resource.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
  authorizer_id    = aws_api_gateway_api_key.apikey.id
}

resource "aws_api_gateway_integration" "getUserByJwt_integration" {
  rest_api_id             = aws_api_gateway_rest_api.bogus_api.id
  resource_id             = aws_api_gateway_resource.userByJwt_resource.id
  http_method             = aws_api_gateway_method.getUserByJwt_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.getUserByJwt.invoke_arn
}

# /self
resource "aws_api_gateway_resource" "self_resource" {
  rest_api_id = aws_api_gateway_rest_api.bogus_api.id
  parent_id   = aws_api_gateway_rest_api.bogus_api.root_resource_id
  path_part   = "self"
}

resource "aws_api_gateway_method" "getSelf_method" {
  rest_api_id = aws_api_gateway_rest_api.bogus_api.id
  resource_id = aws_api_gateway_resource.self_resource.id
  http_method = "GET"

  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.jwt.id
}

resource "aws_api_gateway_integration" "getSelf_integration" {
  rest_api_id             = aws_api_gateway_rest_api.bogus_api.id
  resource_id             = aws_api_gateway_resource.self_resource.id
  http_method             = aws_api_gateway_method.getSelf_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.getSelf.invoke_arn
}

# /state CRUD
resource "aws_api_gateway_resource" "state_resource" {
  rest_api_id = aws_api_gateway_rest_api.bogus_api.id
  parent_id   = aws_api_gateway_rest_api.bogus_api.root_resource_id
  path_part   = "state"
}

resource "aws_api_gateway_resource" "stateUserId_resource" {
  rest_api_id = aws_api_gateway_rest_api.bogus_api.id
  parent_id   = aws_api_gateway_resource.state_resource.id
  path_part   = "{userId}"
}

resource "aws_api_gateway_method" "getState_method" {
  rest_api_id = aws_api_gateway_rest_api.bogus_api.id
  resource_id = aws_api_gateway_resource.stateUserId_resource.id
  http_method = "GET"

  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.jwt.id
}

resource "aws_api_gateway_integration" "getState_integration" {
  rest_api_id             = aws_api_gateway_rest_api.bogus_api.id
  resource_id             = aws_api_gateway_resource.stateUserId_resource.id
  http_method             = aws_api_gateway_method.getState_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.getState.invoke_arn
}

resource "aws_api_gateway_method" "postState_method" {
  rest_api_id = aws_api_gateway_rest_api.bogus_api.id
  resource_id = aws_api_gateway_resource.stateUserId_resource.id
  http_method = "POST"

  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.jwt.id
}

resource "aws_api_gateway_integration" "postState_integration" {
  rest_api_id             = aws_api_gateway_rest_api.bogus_api.id
  resource_id             = aws_api_gateway_resource.stateUserId_resource.id
  http_method             = aws_api_gateway_method.postState_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.postState.invoke_arn
}

resource "aws_api_gateway_method" "deleteState_method" {
  rest_api_id = aws_api_gateway_rest_api.bogus_api.id
  resource_id = aws_api_gateway_resource.stateUserId_resource.id
  http_method = "DELETE"

  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.jwt.id
}

resource "aws_api_gateway_integration" "deleteState_integration" {
  rest_api_id             = aws_api_gateway_rest_api.bogus_api.id
  resource_id             = aws_api_gateway_resource.stateUserId_resource.id
  http_method             = aws_api_gateway_method.deleteState_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.deleteState.invoke_arn
}

# /reflect
resource "aws_api_gateway_resource" "reflect_resource" {
  rest_api_id = aws_api_gateway_rest_api.bogus_api.id
  parent_id   = aws_api_gateway_rest_api.bogus_api.root_resource_id
  path_part   = "reflect"
}

resource "aws_api_gateway_method" "postReflect_method" {
  rest_api_id = aws_api_gateway_rest_api.bogus_api.id
  resource_id = aws_api_gateway_resource.reflect_resource.id
  http_method = "POST"

  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.jwt.id
}

resource "aws_api_gateway_integration" "postReflect_integration" {
  rest_api_id             = aws_api_gateway_rest_api.bogus_api.id
  resource_id             = aws_api_gateway_resource.reflect_resource.id
  http_method             = aws_api_gateway_method.postReflect_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.postReflect.invoke_arn
}

resource "aws_api_gateway_method" "postReflectOpts_method" {
  rest_api_id   = aws_api_gateway_rest_api.bogus_api.id
  resource_id   = aws_api_gateway_resource.reflect_resource.id
  http_method   = "OPTIONS"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.jwt.id
}

resource "aws_api_gateway_integration" "postReflectOpts_integration" {
  rest_api_id             = aws_api_gateway_rest_api.bogus_api.id
  resource_id             = aws_api_gateway_resource.reflect_resource.id
  http_method             = aws_api_gateway_method.postReflectOpts_method.http_method
  integration_http_method = "OPTIONS"
  type                    = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "postReflectOpts_response" {
  rest_api_id = aws_api_gateway_rest_api.bogus_api.id
  resource_id = aws_api_gateway_resource.reflect_resource.id
  http_method = aws_api_gateway_method.postReflectOpts_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "postReflectOpts_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.bogus_api.id
  resource_id = aws_api_gateway_resource.reflect_resource.id
  http_method = aws_api_gateway_method.postReflectOpts_method.http_method
  status_code = aws_api_gateway_method_response.postReflectOpts_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [
    aws_api_gateway_method.postReflectOpts_method,
    aws_api_gateway_integration.postReflectOpts_integration,
  ]
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.getUserById_integration,
    aws_api_gateway_integration.getUserByJwt_integration,
    aws_api_gateway_integration.getSelf_integration,
    aws_api_gateway_integration.getState_integration,
    aws_api_gateway_integration.postState_integration,
    aws_api_gateway_integration.deleteState_integration,
    aws_api_gateway_integration.postReflect_integration,
    aws_api_gateway_integration.postReflectOpts_integration,
  ]
  rest_api_id = aws_api_gateway_rest_api.bogus_api.id
}

resource "aws_api_gateway_stage" "lambda" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.bogus_api.id
  stage_name    = "dev"
}
