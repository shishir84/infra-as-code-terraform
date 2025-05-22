variable "elasticache_clusters" {
  type = list(object({
    cluster_id          = string
    engine_version      = string
    node_type           = string
    num_cache_nodes     = number
    subnet_ids          = list(string)
    security_group_name = string
    maintenance_window  = string
    tags                = map(string)
    vpc_id              = string
  }))
}

# Create Security Group per cluster
resource "aws_security_group" "elasticache_sg" {
  for_each = { for cluster in var.elasticache_clusters : cluster.cluster_id => cluster }

  name        = each.value.security_group_name
  description = "Security group for ElastiCache cluster ${each.key}"
  vpc_id      = each.value.vpc_id

  # You can customize ingress and egress as needed here; example open Redis port:
  ingress {
    description      = "Allow Redis traffic"
    from_port        = 6379
    to_port          = 6379
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]  # Change to your CIDRs or security groups as needed
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = each.value.tags
}

resource "aws_elasticache_subnet_group" "this" {
  for_each = { for cluster in var.elasticache_clusters : cluster.cluster_id => cluster }

  name       = "${each.key}-subnet-group"
  subnet_ids = each.value.subnet_ids

  tags = each.value.tags
}

resource "aws_elasticache_cluster" "this" {
  for_each = { for cluster in var.elasticache_clusters : cluster.cluster_id => cluster }

  cluster_id           = each.value.cluster_id
  engine               = "redis"
  engine_version       = each.value.engine_version
  node_type            = each.value.node_type
  num_cache_nodes      = each.value.num_cache_nodes
  subnet_group_name    = aws_elasticache_subnet_group.this[each.key].name
  security_group_ids   = [aws_security_group.elasticache_sg[each.key].id]
  maintenance_window   = each.value.maintenance_window

  tags = each.value.tags
}
