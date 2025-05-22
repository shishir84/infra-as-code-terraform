variable "eks_clusters" {
  type = list(object({
    name        = string
    version     = string
    vpc_id      = string
    subnet_ids_raw = string
    node_group = object({
      name            = string
      instance_type   = string
      desired_capacity = number
      min_size        = number
      max_size        = number
    })
    tags = map(string)
  }))
}

locals {
  eks_clusters_map = {
    for cluster in var.eks_clusters : cluster.name => cluster
  }
}

resource "aws_eks_cluster" "this" {
  for_each = local.eks_clusters_map

  name     = each.value.name
  version  = each.value.version
  role_arn = aws_iam_role.eks_cluster[each.key].arn

  vpc_config {
    subnet_ids = split(",", each.value.subnet_ids_raw)
  }

  tags = each.value.tags
}

resource "aws_iam_role" "eks_cluster" {
  for_each = local.eks_clusters_map

  name = "${each.key}-eks-cluster-role"

  assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json
}

data "aws_iam_policy_document" "eks_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_eks_node_group" "this" {
  for_each       = local.eks_clusters_map
  cluster_name   = aws_eks_cluster.this[each.key].name
  node_group_name = each.value.node_group.name
  node_role_arn  = aws_iam_role.eks_node[each.key].arn
  subnet_ids     = split(",", each.value.subnet_ids_raw)

  scaling_config {
    desired_size = each.value.node_group.desired_capacity
    min_size     = each.value.node_group.min_size
    max_size     = each.value.node_group.max_size
  }

  instance_types = [each.value.node_group.instance_type]

  tags = each.value.tags
}

resource "aws_iam_role" "eks_node" {
  for_each = local.eks_clusters_map

  name = "${each.key}-eks-node-role"

  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role.json
}

data "aws_iam_policy_document" "eks_node_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
