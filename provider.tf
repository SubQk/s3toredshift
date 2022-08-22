terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region     = "ap-northeast-1"
  access_key = ""
  secret_key = ""
}