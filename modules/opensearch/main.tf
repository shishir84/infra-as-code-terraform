resource "aws_opensearch_domain" "this" {
  for_each = { for domain in var.opensearch_domains : domain.domain_name => domain }

  domain_name    = each.value.domain_name
  engine_version = each.value.engine_version

  cluster_config {
    instance_type  = each.value.instance_type
    instance_count = each.value.instance_count
  }

  ebs_options {
    ebs_enabled = true
    volume_size = each.value.ebs_volume_size
    volume_type = "gp3"
  }

  domain_endpoint_options {
    enforce_https = true
    # You can optionally enable a custom TLS certificate here if you want
    # tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  dynamic "advanced_security_options" {
    for_each = each.value.enable_fine_grained_access ? [1] : []

    content {
      enabled                        = true
      internal_user_database_enabled = true

      master_user_options {
        master_user_name     = each.value.master_user_name
        master_user_password = each.value.master_user_password
      }
    }
  }

  dynamic "node_to_node_encryption" {
    for_each = each.value.enable_fine_grained_access ? [1] : []

    content {
      enabled = true
    }
  }

  dynamic "encrypt_at_rest" {
    for_each = each.value.enable_fine_grained_access ? [1] : []

    content {
      enabled = true
    }
  }

  access_policies = (
    each.value.access_policies == "open-access" ?
    jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect = "Allow"
        Principal = "*"
        Action = "es:*"
        Resource = "*"
      }]
    }) :
    each.value.access_policies
  )

  tags = merge({
    ManagedBy = "Terraform"
  }, each.value.tags)
}
