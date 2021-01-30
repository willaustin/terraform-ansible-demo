terraform {
  # for the sake of this code sample remote state isn't necessary,
  # but it is highly recommended with actual use
  # backend "s3" {
  #   bucket = "mybucket"
  #   key    = "path/to/my/key"
  #   region = "us-east-1"
  # }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  profile = "<replace with your aws profile>"
  region  = "us-west-2"
}
