#Displays the below values in the output section of terraform plan/apply.action

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "bastion_pubilc_ip" {
  value = module.bastion.bastion_public_ip
}


output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "grafana_url" {
  value = module.monitoring.grafana_url
}

output "prometheus_url" {
  value = module.monitoring.prometheus_url
}

