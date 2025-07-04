terraform {  
  backend "s3" {  
    bucket       = "selva-terraform-state-bucket"
    key          = "base-infra.tfstate"  
    region       = "eu-west-1"  
    encrypt      = true  
    use_lockfile = true  #S3 native locking
  }  
}

provider "aws" {
  region = var.region
}