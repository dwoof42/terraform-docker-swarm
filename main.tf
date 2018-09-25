
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "us-west-2"
}



terraform {
  required_version = ">= 0.8"
  backend "s3" {
    bucket = "dtf-terraform-state"
    key    = "workswarm.tfstate"
    region = "us-east-1"
  }
}
