terraform {
  required_version = "~>1.15.0"

  cloud {

    organization = "gangyao-terrafrom-learn"

    workspaces {
      name = "3-tier-with-ha"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}