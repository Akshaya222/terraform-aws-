terraform {
  backend "s3" {
    bucket         = "akshaya-terraform-state-bucket"
    key            = "state/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}