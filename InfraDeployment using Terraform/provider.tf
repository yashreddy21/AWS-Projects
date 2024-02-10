terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.26.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
  #shared_config_files      = ["/home/ubuntu/config.json"]
  shared_credentials_files = ["/home/vagrant/.aws/credentials"]
  #profile                  = "customprofile"
}