#Bastion host module to create a bastion host in the public subnet of the VPC.

resource "aws_instance" "bastion" {

    ami = var.ami_id
    instance_type = var.instance_type
    key_name = var.key_name
    subnet_id = var.public_subnet_id
    vpc_security_group_ids = [var.bastion_sg_id]

user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              echo "Welcome to the Bastion Host"
              EOF
            

    tags = { Name = "${var.env}-bastion" }
  
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

#copying the public key to the bastion host for SSH access

#scp -i yourkey.pem yourkey.pem ec2-user@$ aws_instance.bastion.public_ip:/home/ec2-user/

#SSH into the bastion host

#ssh -i yourkey.pem ec2-user@$ aws_instance.bastion.public_ip

#From the bastion host, you can SSH into the private EC2 instances using their private IPs and the same key pair.
#chmod 400 yourkey.pem
#ssh -i yourkey.pem ec2-user@private_ip_of_app_ec2