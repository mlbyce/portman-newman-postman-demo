resource "aws_dynamodb_table" "bogus_state" {
  name           = "${var.dynamodb_table}-${var.stage}-${random_string.seed.id}"
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