#RDS configuration

resource "aws_db_subnet_group" "main" {
    name = "${var.env}-db-subnet-group"
    subnet_ids = var.db_subnet_ids
    tags = { Name = "${var.env}-db-subnet-group" }
}

resource "aws_db_parameter_group" "main" {
    name = "${var.env}-mysql-params"
    family = "mysql8.0"

    parameter {
        name = "character_set_server"
        value = "utf8mb4"
    }
}


resource "aws_db_instance" "main" {
    identifier = "${var.env}-mysql"
    engine = "mysql"
    engine_version = "8.0"
    instance_class = var.db_instance_class
    allocated_storage = 20
    max_allocated_storage = 100
    storage_type = "gp2"
    storage_encrypted = true
    db_name = var.db_name
    username = var.db_username
    password = var.db_password

    db_subnet_group_name = aws_db_subnet_group.main.name
    parameter_group_name = aws_db_parameter_group.main.name
    vpc_security_group_ids = [var.rds_sg_id]

    backup_retention_period = 7
    backup_window = "03:00-04:00"
    maintenance_window = "mon:04:00-mon:05:00"


    skip_final_snapshot = true
    deletion_protection = false
    multi_az = false

    tags = {
        Name = "${var.env}-mysql"
}
}   