terraform {
  required_version = ">= 0.11.7"

  backend "s3" {
    bucket = "tf-infra-state-bucket"
    key    = "oci/test/identity/terraform.tfstate"
    region = "us-east-2"
  }
}
