# Monitoring Module

#Prometheus collects metrics from en2 instances via NODE exporters 

#Grafana is used to visualize the metrics collected by Prometheus and create dashboards for monitoring the performance of en2 instances.


resource "aws_instance" "monitoring" {

  ami                    = var.ami_id
  instance_type          = "t2.micro"
  key_name               = var.keyname
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.monitoring_sg_id]

  user_data = base64encode(<<-EOF
#!/bin/bash
set -xe

dnf install -y docker

systemctl enable docker
systemctl start docker

sleep 20

mkdir -p /etc/prometheus

cat > /etc/prometheus/prometheus.yml <<PROMEOF
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "node"

    static_configs:
      - targets: ["10.0.1.191:9100", "10.0.3.142:9100"]


PROMEOF

sudo docker run -d --name prometheus --restart always -p 9090:9090 -v /etc/prometheus:/etc/prometheus prom/prometheus --config.file=/etc/prometheus/prometheus.yml

sudo docker run -d --name grafana --restart always -p 3000:3000 -e GF_SECURITY_ADMIN_PASSWORD=admin grafana/grafana

sudo docker run -d --name node-exporter --restart always -p 9100:9100 prom/node-exporter

echo "Monitoring setup complete"
EOF
)

  tags = {
    Name = "${var.env}-monitoring"
  }
}