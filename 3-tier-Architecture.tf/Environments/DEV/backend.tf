#linking s3 bucket as remote backend for storing statefile
  
  terraform {
    backend "s3" {
      bucket = "yuvaraj-terraform-remote-backend"
      key = "dev/terraform.tfstate"
      region = "ap-south-1"
      dynamodb_table = "terraform-state-lock"
      encrypt = true
    }
  }