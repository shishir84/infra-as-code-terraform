provider "aws" {
  region = "us-east-1"
}

module "ec2" {
  source    = "../../modules/ec2"
  instances = var.ec2_resources
}

module "rds" {
  source = "../../modules/rds"
}

module "opensearch" {
  source             = "../../modules/opensearch"
  opensearch_domains = var.opensearch_domains
}

module "s3" {
  source      = "../../modules/s3"
  s3_buckets  = var.s3_buckets
}

module "efs" {
  source        = "../../modules/efs"
  efs_filesystems = var.efs_filesystems
}

module "msk" {
  source = "../../modules/msk"
  msk_clusters = var.msk_clusters
}

module "elasticache" {
  source = "../../modules/elasticache"

  elasticache_clusters = var.elasticache_clusters
}

module "eks" {
  source = "../../modules/eks"
  eks_clusters = var.eks_clusters
}