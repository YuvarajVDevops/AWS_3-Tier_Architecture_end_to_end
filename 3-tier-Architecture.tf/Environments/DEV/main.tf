# Root File for calling every module and creating the infrastructure in DEV environment.


# Calling VPC module and passing the required variables.

module "vpc" {
  source = "../../Modules/VPC"
  env = var.env
  vpc_cidr = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr   
    private_subnet_cidr = var.private_subnet_cidr
    db_subnet_cidr = var.db_subnet_cidr
    availability_zones = var.availability_zones
}



module "bastion" {
  source = "../../Modules/bastion"
  env = var.env
  ami_id = var.ami_id
  instance_type = "t2.micro"
  key_name = var.key_name
  public_subnet_id = module.vpc.public_subnet_ids[0]
  bastion_sg_id = module.vpc.bastion_sg_id
}

module "alb" {
  source = "../../Modules/ALB"
  env = var.env
  vpc_id = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id = module.vpc.alb_sg_id
}

module "ec2" {
  source = "../../Modules/EC2"
  env = var.env
  ami_id = var.ami_id
  instance_type = var.instance_type
  key_name = var.key_name
  app_sg_id = module.vpc.app_sg_id
  private_subnet_ids = module.vpc.private_subnet_ids
  target_group_arn = module.alb.app_target_group_arn
  min_size = 1
  max_size = 3
  desired_capacity = 2
}

module "rds" {
  source = "../../Modules/RDS"
  env = var.env
  db_subnet_ids = module.vpc.db_subnet_ids
  rds_sg_id = module.vpc.rds_sg_id
  db_instance_class = var.db_instance_class
  db_name = var.db_name
  db_username = var.db_username
  db_password = var.db_password
}



module "monitoring" {
  source = "../../Modules/Monitoring"
  env = var.env
  ami_id = var.ami_id
  keyname = var.key_name
  public_subnet_id = module.vpc.public_subnet_ids[0]
  monitoring_sg_id = module.vpc.monitoring_sg_id
  vpc_cidr = var.vpc_cidr
}






