variable "region" {
  description = "Região da AWS"
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "ID da VPC existente"
}

variable "subnet_ids" {
  description = "Lista de subnets privadas para o Aurora"
  type        = list(string)
}

variable "db_username" {
  description = "Usuário master do PostgreSQL RDS"

  validation {
    condition = !contains([
      "admin",
      "postgres",
      "root",
      "rdsadmin"
    ], lower(var.db_username))
    error_message = "DB_USERNAME usa um nome reservado pelo PostgreSQL RDS. Use, por exemplo, dbadmin."
  }
}

variable "db_password" {
  description = "Senha master do PostgreSQL RDS"
  sensitive   = true
}

variable "run_migrations" {
  description = "Controla se o Terraform deve executar os scripts DDL/DML via provisioner local-exec (use somente quando o runner tiver acesso à VPC)."
  type        = bool
  default     = true
}
