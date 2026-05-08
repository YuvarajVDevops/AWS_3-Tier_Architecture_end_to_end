# RDS Outputs


output "rds_endpoint" {
  value = aws_db_instance.main.endpoint
  description = "The connection endpoint for the RDS instance"
}

output "rds_port" {
  value = aws_db_instance.main.port
  description = "The port on which the RDS instance is listening"
}

output "rds_db_name" {
    value = aws_db_instance.main.db_name
    description = "The name of the database created in the RDS instance"
}

