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
    cidr_blocks = ["0.0.0.0/0"] # ajuste conforme sua rede
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################################
# Instancia PostgreSQL RDS para o Free Tier
############################################

resource "aws_db_instance" "postgres" {
  identifier = "workshop"

  engine         = "postgres"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "workshop"
  username = var.db_username
  password = var.db_password
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.aurora_subnets.name
  vpc_security_group_ids = [aws_security_group.aurora_sg.id]

  publicly_accessible     = true
  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false
  apply_immediately       = true
}

############################################
# PostgreSQL DDL
############################################

resource "null_resource" "run_ddl" {
  count = var.run_migrations ? 1 : 0

  triggers = {
    script_hash = filesha256("../../scripts/ddl.sql")
  }

  depends_on = [
    aws_db_instance.postgres
  ]

  provisioner "local-exec" {
    command = <<-EOT
      PGPASSWORD='${var.db_password}' psql \
      -v ON_ERROR_STOP=1 \
      -h ${aws_db_instance.postgres.address} \
      -U ${var.db_username} \
      -d workshop \
      -f ../../scripts/ddl.sql
    EOT
  }
}


############################################
# PostgreSQL DML
############################################

resource "null_resource" "run_dml" {
  count = var.run_migrations ? 1 : 0

  triggers = {
    script_hash = filesha256("../../scripts/dml.sql")
  }

  depends_on = [
    null_resource.run_ddl
  ]

  provisioner "local-exec" {
    command = <<-EOT
    PGPASSWORD='${var.db_password}' psql \
      -v ON_ERROR_STOP=1 \
      -h ${aws_db_instance.postgres.address} \
      -U ${var.db_username} \
      -d workshop \
      -f ../../scripts/dml.sql
    EOT
  }
}

