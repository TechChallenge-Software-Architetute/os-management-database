output "aurora_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "aurora_port" {
  value = 5432
}

output "aurora_database" {
  value = "workshop"
}

output "aurora_jdbc_url" {
  value     = "jdbc:postgresql://${aws_db_instance.postgres.address}:5432/workshop"
  sensitive = true
}