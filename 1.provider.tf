terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 3.0"  }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"  }
  }
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "ap-south-1"
  access_key = "ACCESS-KEY"
  secret_key = "SECRET_KEY"
}

terraform {
  backend "s3" {
    bucket         = "saiterra"   # S3 bucket name
    key            = "terraform.tfstate"   # path inside bucket
    region         = "ap-south-1"
#    dynamodb_table = "terraform-lock-table"        # for state locking
    encrypt        = true
  }
}
