variable "dynamodb_table" {
  description = "name of the ddb table"
  type = string
  default = "bogus_state"
}

resource "aws_dynamodb_table" "bogus_state" {
  name           = var.dynamodb_table
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