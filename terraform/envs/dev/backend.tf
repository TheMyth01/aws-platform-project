terraform {
  backend "s3" {
    bucket         = "aws-platform-tfstate-inaam-ew2"
    key            = "dev/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "aws-platform-tf-lock"
    encrypt        = true
  }
}
