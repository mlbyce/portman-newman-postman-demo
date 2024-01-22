resource "aws_dynamodb_table" "bogus_state" {
  name           = "${local.api_state_table}-${local.uniq_stage}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "userId"
  range_key      = "stateName"

  attribute {
    name = "userId"
    type = "S"
  }
  
  attribute {
    name = "stateName"
    type = "S"
  }
}