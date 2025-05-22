provider "aws" {
  alias  = "bucket_provider"
  region = var.s3_buckets[0].region
}

resource "aws_s3_bucket" "this" {
  for_each = { for b in var.s3_buckets : b.bucket_name => b }

  bucket = each.value.bucket_name
  acl    = each.value.acl

  tags = merge(
    {
      ManagedBy = "Terraform"
    },
    each.value.tags
  )
}

resource "aws_s3_bucket_versioning" "versioning" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id

  versioning_configuration {
    status = each.value.versioning ? "Enabled" : "Suspended"
  }
}
