resource "aws_db_subnet_group" "rds_subnet_group" {
  count      = length(var.rds_instances)
  name       = var.rds_instances[count.index].db_subnet_group_name
  subnet_ids = split(",", var.rds_instances[count.index].subnet_ids_raw)

  tags = {
    Name = var.rds_instances[count.index].db_subnet_group_name
  }
}

resource "aws_security_group" "rds_sg" {
  count       = length(var.rds_instances)
  name        = "${var.rds_instances[count.index].identifier}-sg"
  description = "Security group for RDS instance ${var.rds_instances[count.index].identifier}"
  vpc_id      = var.rds_instances[count.index].vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # ⚠️ Wide open — restrict in production
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.rds_instances[count.index].identifier}-sg"
  }
}

resource "aws_db_instance" "postgresql" {
  count                     = length(var.rds_instances)

  depends_on = [
    aws_db_subnet_group.rds_subnet_group,
    aws_security_group.rds_sg
  ]

  identifier                = var.rds_instances[count.index].identifier
  engine                    = "postgres"
  engine_version            = var.rds_instances[count.index].engine_version
  instance_class            = var.rds_instances[count.index].instance_class
  allocated_storage         = var.rds_instances[count.index].allocated_storage
  db_name                   = var.rds_instances[count.index].db_name
  username                  = var.rds_instances[count.index].username
  password                  = var.rds_instances[count.index].password
  vpc_security_group_ids    = [aws_security_group.rds_sg[count.index].id]
  db_subnet_group_name      = aws_db_subnet_group.rds_subnet_group[count.index].name
  multi_az                  = var.rds_instances[count.index].multi_az
  publicly_accessible       = var.rds_instances[count.index].publicly_accessible
  backup_retention_period   = var.rds_instances[count.index].backup_retention_period

  storage_encrypted         = true
  kms_key_id                = var.rds_instances[count.index].kms_key_id

  skip_final_snapshot       = true
  tags                      = var.rds_instances[count.index].tags

  delete_automated_backups = true
}
