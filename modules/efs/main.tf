variable "efs_filesystems" {
  description = "List of EFS filesystems"
  type = list(object({
    filesystem_name                   = string
    performance_mode                  = string
    encrypted                         = bool
    kms_key_id                        = string
    throughput_mode                   = string
    provisioned_throughput_in_mibps   = number
    subnet_ids                        = list(string)
    vpc_id                            = string
    allowed_cidrs                     = list(string)
    tags                              = map(string)
    notes                             = string
  }))
}

resource "aws_efs_file_system" "this" {
  for_each = { for fs in var.efs_filesystems : fs.filesystem_name => fs }

  creation_token      = each.value.filesystem_name
  performance_mode    = each.value.performance_mode
  encrypted           = each.value.encrypted
  kms_key_id          = each.value.encrypted ? each.value.kms_key_id : null
  throughput_mode     = each.value.throughput_mode

  provisioned_throughput_in_mibps = (
    each.value.throughput_mode == "provisioned" && each.value.provisioned_throughput_in_mibps != null
    ? each.value.provisioned_throughput_in_mibps
    : null
  )

  tags = merge(
    {
      ManagedBy = "Terraform"
    },
    each.value.tags
  )
}

resource "aws_security_group" "efs_sg" {
  for_each    = { for efs in var.efs_filesystems : efs.filesystem_name => efs }
  name        = "${each.value.filesystem_name}-efs-sg"
  description = "Security group for EFS ${each.value.filesystem_name}"
  vpc_id      = each.value.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = each.value.allowed_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    each.value.tags,
    {
      "Name" = "${each.value.filesystem_name}-efs-sg"
    }
  )
}


resource "aws_efs_mount_target" "this" {
  for_each = { for fs in var.efs_filesystems : fs.filesystem_name => fs }

  file_system_id  = aws_efs_file_system.this[each.key].id
  subnet_id       = element(each.value.subnet_ids, 0)
  #security_groups = each.value.security_group_ids
}
