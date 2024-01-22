variable "region" {
    type=string
    description = "AWS Region where deploying resources"
}

locals {
  tf-state-bucket = "bogus-api-tf-state"
  tf-state-table  = "bogus-api-tf-locks"
}
