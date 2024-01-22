variable "region" {
    type=string
    description = "AWS Region where deploying resources"
    default = "us-east-1"
}

variable "stage" {
    type=string
    description = "Deployment stage [dev | stg | test | prd | whatever]"
}

locals {
  uniq_stage = "${var.stage}-${random_string.seed.id}"
  api_state_table = "bogus_state"
  tf-state-bucket = "bogus-api-tf-state"
  tf-state-table  = "bogus-api-tf-locks"
  tf-state-key  = "bogus-api/${var.stage}/tfstate"
}

