provider "aws" {
  region = "us-east-1"
  access_key = "AKIAQVJHCTOYVGD7GJEX"
  secret_key = "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"
}

module "calling-module-1" {
  source = ".//module-1"
}
