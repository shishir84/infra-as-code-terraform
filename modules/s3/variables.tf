variable "s3_buckets" {
  type = list(object({
    bucket_name = string
    region      = string
    versioning  = bool
    acl         = string
    tags        = map(string)
    notes       = string
  }))
}
