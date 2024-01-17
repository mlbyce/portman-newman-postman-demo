variable "region" {
    type=string
    description = "AWS Region where deploying resources"
    default = "us-east-1"
}

variable "stage" {
    type=string
    description = "Deployment stage [dev | stg | test | prd | whatever]"
    default="dev"
}

variable "dynamodb_table" {
  description = "name of the ddb table"
  type = string
  default = "bogus_state"
}
