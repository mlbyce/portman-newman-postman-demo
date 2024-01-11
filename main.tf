resource "aws_lambda_function" "postReflect" {
  filename         = "postReflectIndex.zip"
  function_name    = "postReflect"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  source_code_hash = data.archive_file.postReflect_package.output_base64sha256
}

resource "aws_lambda_function" "getSelf" {
  filename         = "getSelfIndex.zip"
  function_name    = "getSelf"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  source_code_hash = data.archive_file.getSelf_package.output_base64sha256
}

resource "aws_lambda_function" "getUserById" {
  filename         = "getUserByIdIndex.zip"
  function_name    = "getUserById"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  source_code_hash = data.archive_file.getUserById_package.output_base64sha256
}

resource "aws_lambda_function" "getUserByJwt" {
  filename         = "getUserByJwtIndex.zip"
  function_name    = "getUserByJwt"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  source_code_hash = data.archive_file.getUserByJwt_package.output_base64sha256
}

resource "aws_lambda_function" "getState" {
  filename         = "getStateIndex.zip"
  function_name    = "getState"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  environment {
    variables = {
      DDB_TABLE = var.dynamodb_table
    }
  }
  source_code_hash = data.archive_file.getState_package.output_base64sha256
}

resource "aws_lambda_function" "postState" {
  filename         = "postStateIndex.zip"
  function_name    = "postState"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  environment {
    variables = {
      DDB_TABLE = var.dynamodb_table
    }
  }
  source_code_hash = data.archive_file.postState_package.output_base64sha256
}

resource "aws_lambda_function" "deleteState" {
  filename         = "deleteStateIndex.zip"
  function_name    = "deleteState"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  environment {
    variables = {
      DDB_TABLE = var.dynamodb_table
    }
  }
  source_code_hash = data.archive_file.deleteState_package.output_base64sha256
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_role_policy_attachment" "idp_readonly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonCognitoReadOnly"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_role_policy_attachment" "ddb_full" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_lambda_permission" "apigw_lambda_postReflect" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.postReflect.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.bogus_api.execution_arn}/*/POST/reflect"
}

resource "aws_lambda_permission" "apigw_lambda_getSelf" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.getSelf.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.bogus_api.execution_arn}/*/GET/self"
}

resource "aws_lambda_permission" "apigw_lambda_getUserById" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.getUserById.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.bogus_api.execution_arn}/*/GET/user-by-id"
}

resource "aws_lambda_permission" "apigw_lambda_getUserByJwt" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.getUserByJwt.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.bogus_api.execution_arn}/*/GET/user-by-jwt"
}

resource "aws_lambda_permission" "apigw_lambda_getState" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.getState.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.bogus_api.execution_arn}/*/GET/state/*"
}

resource "aws_lambda_permission" "apigw_lambda_postState" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.postState.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.bogus_api.execution_arn}/*/POST/state/*"
}

resource "aws_lambda_permission" "apigw_lambda_deleteState" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.deleteState.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.bogus_api.execution_arn}/*/DELETE/state/*"
}

data "archive_file" "postReflect_package" {
  type        = "zip"
  source_file = "src/postReflect/dist/index.js"
  output_path = "postReflectIndex.zip"
}

data "archive_file" "getSelf_package" {
  type        = "zip"
  source_file  = "src/getSelf/dist/index.js"
  output_path = "getSelfIndex.zip"
}

data "archive_file" "getUserById_package" {
  type        = "zip"
  source_file = "src/getUserById/dist/index.js"
  output_path = "getUserByIdIndex.zip"
}

data "archive_file" "getUserByJwt_package" {
  type        = "zip"
  source_file = "src/getUserByJwt/dist/index.js"
  output_path = "getUserByJwtIndex.zip"
}

data "archive_file" "getState_package" {
  type        = "zip"
  source_file = "src/getState/dist/index.js"
  output_path = "getStateIndex.zip"
}

data "archive_file" "postState_package" {
  type        = "zip"
  source_file = "src/postState/dist/index.js"
  output_path = "postStateIndex.zip"
}

data "archive_file" "deleteState_package" {
  type        = "zip"
  source_file  = "src/deleteState/dist/index.js"
  output_path = "deleteStateIndex.zip"
}
