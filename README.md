# AWS_3-Tier_Architecture_end_to_end

**AWS Terraform Infrastructure & Monitoring Project**

**Project Overview**

This project is a production-style AWS cloud infrastructure deployment built using Terraform with a modular architecture approach. The infrastructure includes networking, compute, load balancing, auto scaling, monitoring, and database components along with centralized observability using Prometheus and Grafana.

The goal of this project was to gain hands-on experience with:

Infrastructure as Code (IaC)
AWS networking and security
Terraform modular design
Dockerized application deployment
Auto Scaling infrastructure
Monitoring and observability
Linux and cloud troubleshooting
Architecture Flow

Internet User ↓ Application Load Balancer (ALB) ↓ Auto Scaling Group (ASG) ↓ Private EC2 Instances (Dockerized Nginx) ↓ RDS MySQL Database

Monitoring Flow:

Node Exporter ↓ Prometheus ↓ Grafana

AWS Services Used
Networking
VPC
Public Subnets
Private Subnets
DB Subnets
Internet Gateway
NAT Gateway
Route Tables
Compute & Application
EC2
Launch Template
Auto Scaling Group
Application Load Balancer
Target Groups
Docker
Nginx Container
Database
RDS MySQL
DB Subnet Group
DB Parameter Group
Monitoring & Observability
Prometheus
Grafana
Node Exporter
CloudWatch Alarms
Project Structure
.
├── Modules/
│   ├── VPC/
│   ├── Security/
│   ├── Bastion/
│   ├── ALB/
│   ├── EC2/
│   ├── RDS/
│   └── Monitoring/
│
├── Environments/
│   └── DEV/
│       ├── main.tf
│       ├── variables.tf
│       ├── terraform.tfvars
│       └── providers.tf
│
└── README.md


**Key Features**

Modular Terraform Architecture
Reusable Terraform modules
Environment separation
Better scalability and maintainability
Secure Network Design
Private EC2 instances
Bastion host access
NAT Gateway for outbound internet access
Security Group-based communication
High Availability
Multi-AZ subnet design
Auto Scaling Group
Application Load Balancer
Health checks
Dockerized Application Deployment
Docker installed automatically using cloud-init/user_data
Nginx container deployed automatically during EC2 launch
Monitoring Stack

**Prometheus scrapes metrics from:**

Monitoring EC2
Application EC2 instances

**Grafana visualizes:**

CPU usage
Memory usage
Disk utilization
Network metrics
Monitoring Architecture

**Monitoring EC2:**

Prometheus
Grafana
Node Exporter

Application EC2:

Node Exporter

Prometheus scrapes Node Exporter metrics from all EC2 instances and Grafana visualizes the metrics using dashboards.

Auto Scaling Configuration
Scale Up

Condition:

CPU utilization > 80%

Action:

Add EC2 instance
Scale Down

Condition:

CPU utilization < 20%

Action:

Remove EC2 instance

**Project Outcome**

Successfully designed, deployed, monitored, and troubleshot a production-style AWS cloud infrastructure using Terraform and Docker while implementing centralized observability using Prometheus and Grafana.

This project provided hands-on experience with real-world cloud infrastructure deployment, debugging, monitoring, auto scaling, and infrastructure automation concepts.

Author

Yuvaraj V

Cloud / DevOps Enthusiast

Focused on:

Cloud Infrastructure
DevOps Automation
Monitoring & Observability
Linux & AWS
