variable "region" {
  default = "ap-northeast-1"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

locals {
  base_name       = "eks-example"
  cluster_name    = "${local.base_name}-cluster"
  key_name        = "your_key_name"
  cluster_version = "1.15"
}