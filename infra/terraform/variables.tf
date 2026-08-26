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
  description = "Usuário master do Aurora"
}

variable "db_password" {
  description = "Senha master do Aurora"
  sensitive   = true
}

variable "run_migrations" {
  description = "Controla se o Terraform deve executar os scripts DDL/DML via provisioner local-exec (use somente quando o runner tiver acesso à VPC)."
  type        = bool
  default     = false
}
