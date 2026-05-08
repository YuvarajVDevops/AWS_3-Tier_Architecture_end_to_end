#Displays the below values in the output section of terraform plan/apply.action

output "asg_name" {
    value = aws_autoscaling_group.app.name
  
}

output "ecr_repo_url" {
    value = aws_ecr_repository.app.repository_url
}

output "launch_template_id" {
    value = aws_launch_template.app.id
}