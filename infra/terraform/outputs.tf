output "aurora_endpoint" {
  value = aws_rds_cluster.aurora.endpoint
}

output "aurora_port" {
  value = 5432
}

output "aurora_database" {
  value = "workshop"
}

output "aurora_jdbc_url" {
  value = "jdbc:postgresql://${aws_rds_cluster.aurora.endpoint}:5432/workshop"
  sensitive = true
}