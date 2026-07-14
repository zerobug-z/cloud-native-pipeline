terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Store state remotely — create the S3 bucket first with:
  # aws s3api create-bucket --bucket cloud-native-tfstate --region us-east-1
  backend "s3" {
    bucket = "cloud-native-tfstate"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}
