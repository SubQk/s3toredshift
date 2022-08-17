terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region     = "ap-northeast-1"
  access_key = "AKIAQRTD7O7HK2FY2YH7"
  secret_key = "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"
}