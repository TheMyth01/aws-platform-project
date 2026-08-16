terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    awscc = {
      source  = "hashicorp/awscc"
      version = "~> 1.94.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# The live BCM Data Export is an Athena output. The native hashicorp/aws
# resource currently validates output_type as CUSTOM only, while the AWS
# CloudFormation/Cloud Control schema supports ATHENA. Use the official
# awscc provider for this one resource instead of changing the live export.
provider "awscc" {
  region = "us-east-1"
}
