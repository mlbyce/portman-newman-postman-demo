terraform {
  ###############################################################
  # To set up for remote state control, navigate to 
  # "remoteStateInit" and deploy the stack with:
  # terraform init / plan / apply
  # 
  # Then, use "./build.sh" with -b (for remote backend) to enable
  # using remote state instead of local.  "./build.sh" uses the
  # $REGION and $STAGE variables to "inject" key and region with 
  # the proper values.  This will modify this source file so you
  # will need make sure to not commit these changes to the repo.
  ###############################################################
  #{{}}backend "s3" {
  #{{}}  bucket         = "bogus-api-tf-state"
  #{{}}  dynamodb_table = "bogus-api-tf-locks"
  #{{}}  encrypt        = true
  #{{}}  key            = "bogus-api/{{STAGE}}/tfstate"
  #{{}}  region         = "{{REGION}}"
  #{{}}}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.10.0"
    }
  }
}

provider "aws" {
  region = var.region
}
