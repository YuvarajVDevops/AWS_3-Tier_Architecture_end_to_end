# Main configuration for EC2 instance


resource "aws_ecr_repository" "app" {
  name = "${var.env}-app"
  image_tag_mutability = "MUTABLE"  
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.env}-app-ecr"
  }
}


#-----------------------LAUNCH TEMPLATE FOR EC2-----------------------

resource "aws_launch_template" "app" {
  name_prefix   = "${var.env}-app-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interfaces {
    security_groups = [var.app_sg_id]
    associate_public_ip_address = false
  }

#-----------------------USER DATA FOR EVRY EC2 GETS CREATED-----------------------
user_data = base64encode(<<-EOF
#!/bin/bash
set -xe
dnf install -y docker 
systemctl enable docker
systemctl start docker
sleep 15

#INSTALL NODE EXPORTER FOR PROMETHEUS MONITORING

wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
tar -xvf node_exporter-1.7.0.linux-amd64.tar.gz
mv node_exporter-1.7.0.linux-amd64/node_exporter /usr/local/bin/
nohup node_exporter &


docker run -d -p 80:80 --name app --restart always nginx
echo "EC2 setup complete"
EOF
)
              


 tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.env}-app-ec2"
    }
  }
}

  #AUTOSCALING CONFIGURATION

resource "aws_autoscaling_group" "app" {

    name                      = "${var.env}-app-asg"
    max_size                  = var.max_size
    min_size                  = var.min_size
    desired_capacity          = var.desired_capacity
    vpc_zone_identifier       = var.private_subnet_ids
    target_group_arns         = [var.target_group_arn]
    health_check_type         = "ELB"

    launch_template {
        id      = aws_launch_template.app.id
        version = aws_launch_template.app.latest_version
    }
    
    tag {
        key                 = "Name"
        value               = "${var.env}-app-ec2"
        propagate_at_launch = true
    }
    }


    #--------------SCALE UP POLICY-----------------

resource "aws_autoscaling_policy" "scale_up" {
    name = "${var.env}-scale-up"
    autoscaling_group_name = aws_autoscaling_group.app.name
    adjustment_type = "ChangeInCapacity"
    scaling_adjustment = 1
    cooldown = 300
}

 #--------------SCALE DOWN POLICY-----------------

resource "aws_autoscaling_policy" "scale_down" {
    name = "${var.env}-scale-down"
    autoscaling_group_name = aws_autoscaling_group.app.name
    adjustment_type = "ChangeInCapacity"
    scaling_adjustment = -1
    cooldown = 300
}

#CLOUDWATCH ALARMS FOR SCALING WHEN CPU UTILIZATION GOES ABOVE 80%

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
    alarm_name = "${var.env}-cpu-high"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods = 2
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = 120
    statistic = "Average"
    threshold = 80
    alarm_description = "Scale up if CPU > 80%"
    alarm_actions = [aws_autoscaling_policy.scale_up.arn]


    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.app.name
    }

}


#CLOUDWATCH ALARMS FOR SCALING WHEN CPU UTILIZATION GOES BELOW 20%

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
    alarm_name = "${var.env}-cpu-low"
    comparison_operator = "LessThanThreshold"
    evaluation_periods = 2
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period = 120
    statistic = "Average"
    threshold = 20
    alarm_description = "Scale down if CPU < 20%"
    alarm_actions = [aws_autoscaling_policy.scale_down.arn]

    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.app.name
    }

}