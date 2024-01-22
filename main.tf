resource "random_string" "seed" {
  length = 6
  special = false
  upper = false
}

resource "aws_lambda_function" "postReflect" {
  filename         = "postReflectIndex-${local.uniq_stage}.zip"
  function_name    = "postReflect-${local.uniq_stage}"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  source_code_hash = data.archive_file.postReflect_package.output_base64sha256
}

resource "aws_lambda_function" "getSelf" {
  filename         = "getSelfIndex-${local.uniq_stage}.zip"
  function_name    = "getSelf-${local.uniq_stage}"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  source_code_hash = data.archive_file.getSelf_package.output_base64sha256
}

resource "aws_lambda_function" "getUserById" {
  filename         = "getUserByIdIndex-${local.uniq_stage}.zip"
  function_name    = "getUserById-${local.uniq_stage}"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  source_code_hash = data.archive_file.getUserById_package.output_base64sha256
}

resource "aws_lambda_function" "getUserByJwt" {
  filename         = "getUserByJwtIndex-${local.uniq_stage}.zip"
  function_name    = "getUserByJwt-${local.uniq_stage}"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  source_code_hash = data.archive_file.getUserByJwt_package.output_base64sha256
}

resource "aws_lambda_function" "getState" {
  filename         = "getStateIndex-${local.uniq_stage}.zip"
  function_name    = "getState-${local.uniq_stage}"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  environment {
    variables = {
      DDB_TABLE = "${local.api_state_table}-${local.uniq_stage}"
    }
  }
  source_code_hash = data.archive_file.getState_package.output_base64sha256
}

resource "aws_lambda_function" "postState" {
  filename         = "postStateIndex-${local.uniq_stage}.zip"
  function_name    = "postState-${local.uniq_stage}"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  environment {
    variables = {
      DDB_TABLE = "${local.api_state_table}-${local.uniq_stage}"
    }
  }
  source_code_hash = data.archive_file.postState_package.output_base64sha256
}

resource "aws_lambda_function" "deleteState" {
  filename         = "deleteStateIndex-${local.uniq_stage}.zip"
  function_name    = "deleteState-${local.uniq_stage}"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  environment {
    variables = {
      DDB_TABLE = "${local.api_state_table}-${local.uniq_stage}"
    }
  }
  source_code_hash = data.archive_file.deleteState_package.output_base64sha256
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-role-${local.uniq_stage}"

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
  output_path = "postReflectIndex-${local.uniq_stage}.zip"
}

data "archive_file" "getSelf_package" {
  type        = "zip"
  source_file  = "src/getSelf/dist/index.js"
  output_path = "getSelfIndex-${local.uniq_stage}.zip"
}

data "archive_file" "getUserById_package" {
  type        = "zip"
  source_file = "src/getUserById/dist/index.js"
  output_path = "getUserByIdIndex-${local.uniq_stage}.zip"
}

data "archive_file" "getUserByJwt_package" {
  type        = "zip"
  source_file = "src/getUserByJwt/dist/index.js"
  output_path = "getUserByJwtIndex-${local.uniq_stage}.zip"
}

data "archive_file" "getState_package" {
  type        = "zip"
  source_file = "src/getState/dist/index.js"
  output_path = "getStateIndex-${local.uniq_stage}.zip"
}

data "archive_file" "postState_package" {
  type        = "zip"
  source_file = "src/postState/dist/index.js"
  output_path = "postStateIndex-${local.uniq_stage}.zip"
}

data "archive_file" "deleteState_package" {
  type        = "zip"
  source_file  = "src/deleteState/dist/index.js"
  output_path = "deleteStateIndex-${local.uniq_stage}.zip"
}
