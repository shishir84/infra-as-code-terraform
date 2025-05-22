variable "msk_clusters" {
  type = list(object({
    cluster_name                = string
    kafka_version               = string
    number_of_broker_nodes      = number
    broker_instance_type        = string
    client_subnets              = list(string)
    kms_key_name                = string
    vpc_id                      = string
    security_group_name         = string
    security_group_description  = string
    tags                        = map(string)
  }))
}

resource "aws_kms_key" "msk" {
  for_each = { for cluster in var.msk_clusters : cluster.cluster_name => cluster }

  description             = "KMS key for MSK cluster ${each.key}"
  key_usage               = "ENCRYPT_DECRYPT"
  enable_key_rotation     = true
  deletion_window_in_days = 10
  tags = each.value.tags
}

resource "aws_kms_alias" "msk" {
  for_each      = { for cluster in var.msk_clusters : cluster.cluster_name => cluster }
  name          = "alias/${each.value.kms_key_name}"
  target_key_id = aws_kms_key.msk[each.key].key_id
}

resource "aws_security_group" "msk" {
  for_each = { for cluster in var.msk_clusters : cluster.cluster_name => cluster }

  name        = each.value.security_group_name
  description = each.value.security_group_description
  vpc_id      = each.value.vpc_id

  ingress {
    from_port   = 9092
    to_port     = 9094
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = each.value.tags
}

resource "aws_msk_cluster" "this" {
  for_each = { for cluster in var.msk_clusters : cluster.cluster_name => cluster }

  depends_on = [
    aws_kms_key.msk,
    aws_security_group.msk
  ]

  cluster_name           = each.value.cluster_name
  kafka_version          = each.value.kafka_version
  number_of_broker_nodes = each.value.number_of_broker_nodes

  broker_node_group_info {
    instance_type   = each.value.broker_instance_type
    client_subnets  = each.value.client_subnets
    security_groups = [aws_security_group.msk[each.key].id]

    storage_info {
      ebs_storage_info {
        volume_size = 100
      }
    }
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = aws_kms_key.msk[each.key].arn
  }

  tags = each.value.tags
}

