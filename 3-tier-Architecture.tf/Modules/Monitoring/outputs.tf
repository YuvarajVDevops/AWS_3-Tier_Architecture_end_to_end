#displaying the output values of the monitoring module

output "monitoring_public_ip" {
  value = aws_instance.monitoring.public_ip
  description = "The public IP address of the monitoring instance"
}

output "grafana_url" {
  value = "http://${aws_instance.monitoring.public_ip}:3000"
  description = "The URL to access Grafana dashboard"
}

output "prometheus_url" {
  value = "http://${aws_instance.monitoring.public_ip}:9090"
  description = "The URL to access Prometheus dashboard"
}

