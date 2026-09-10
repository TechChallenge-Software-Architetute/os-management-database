############################################
# DB Subnet Group
############################################

resource "aws_db_subnet_group" "aurora_subnets" {
  name       = "aurora-workshop-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "Aurora Subnet Group"
  }
}

############################################
# Security Group
############################################

resource "aws_security_group" "aurora_sg" {
  name        = "aurora-security-group"
  description = "Acesso ao Aurora PostgreSQL"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # ajuste conforme sua rede
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################################
# Aurora Cluster
############################################

resource "aws_rds_cluster" "aurora" {
  cluster_identifier = "workshop"
  engine             = "aurora-postgresql"
  engine_version     = "15.4"

  master_username = var.db_username
  master_password = var.db_password
  database_name   = "workshop"

  db_subnet_group_name   = aws_db_subnet_group.aurora_subnets.name
  vpc_security_group_ids = [aws_security_group.aurora_sg.id]

  backup_retention_period = 1
  preferred_backup_window = "03:00-04:00"
}

############################################
# Aurora Instance (Writer)
############################################

resource "aws_rds_cluster_instance" "aurora_instance" {
  identifier         = "workshop-aurora-instance-1"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = "db.t3.medium"
  engine             = aws_rds_cluster.aurora.engine
}

############################################
# Aurora DDL
############################################

resource "null_resource" "run_ddl" {
  count = var.run_migrations ? 1 : 0
  depends_on = [
    aws_rds_cluster_instance.aurora_instance
  ]

  provisioner "local-exec" {
    command = <<-EOT
      PGPASSWORD='${var.db_password}' psql \
      -h ${aws_rds_cluster.aurora.endpoint} \
      -U ${var.db_username} \
      -d workshop \
      -f ../../scripts/ddl.sql
    EOT
  }
}


############################################
# Aurora DML
############################################

resource "null_resource" "run_dml" {
  count = var.run_migrations ? 1 : 0
  depends_on = [
    null_resource.run_ddl
  ]

  provisioner "local-exec" {
    command = <<-EOT
    PGPASSWORD='${var.db_password}' psql \
      -h ${aws_rds_cluster.aurora.endpoint} \
      -U ${var.db_username} \
      -d workshop \
      -f ../../scripts/dml.sql
    EOT
  }
}

