#Displays below values in the output section of terraform plan/apply

output "vpc_id" {

    value = aws_vpc.main.id
}

output "public_subnet_ids" {
  
  value = aws_subnet.public[*].id  # * is used to get the list of all public subnet ids created in the module.
}

output "private_subnet_ids" {
  
  value = aws_subnet.private[*].id  
}

output "db_subnet_ids" {
  value = aws_subnet.db[*].id
}

output "alb_sg_id" {
  value = aws_security_group.alb.id
  
}

output "app_sg_id" {
  value = aws_security_group.app.id
}

output "bastion_sg_id" {
  value = aws_security_group.bastion.id
}

output "rds_sg_id" {
    value = aws_security_group.rds.id
  
}

output "monitoring_sg_id" {
  value = aws_security_group.monitoring.id
}