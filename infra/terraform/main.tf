############################################
# DB Subnet Group
############################################

resource "aws_db_subnet_group" "aurora_subnets" {
  name       = "aurora-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "Aurora Subnet Group"
  }
}

############################################
# Security Group
############################################

resource "aws_security_group" "aurora_sg" {
  name        = "aurora-sg"
  description = "Acesso ao Aurora MySQL"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
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
  engine             = "aurora-mysql"
  engine_version     = "5.7.mysql_aurora.2.11.2"

  master_username = var.db_username
  master_password = var.db_password
  database_name   = "meubanco"

  db_subnet_group_name   = aws_db_subnet_group.aurora_subnets.name
  vpc_security_group_ids = [aws_security_group.aurora_sg.id]

  backup_retention_period = 7
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
  depends_on = [
    aws_rds_cluster_instance.aurora_instance
  ]

  provisioner "local-exec" {
    command = <<EOT
mysql -h ${aws_rds_cluster.aurora.endpoint} \
      -u ${var.db_username} \
      -p${var.db_password} \
      < ../scripts/ddl.sql
EOT
  }
}


############################################
# Aurora DML
############################################

resource "null_resource" "run_dml" {
  depends_on = [
    null_resource.run_ddl
  ]

  provisioner "local-exec" {
    command = <<EOT
mysql -h ${aws_rds_cluster.aurora.endpoint} \
      -u ${var.db_username} \
      -p${var.db_password} \
      < ../scripts/dml.sql
EOT
  }
}

