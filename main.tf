locals {
  vpc_cidr_block  = "10.0.0.0/16"
  key_name        = "your_key_name"
  base_name       = "eks-example"
  cluster_name    = "${local.base_name}-cluster"
  region          = "ap-northeast-1"
  cluster_version = "1.15"
}

provider "aws" {
  region = local.region
}