data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"]
}



resource "aws_security_group" "public-sec-group" {
    
    vpc_id      = var.vpc-id

    ingress {
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    ingress {
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "public-sec-group"
        
    }
}




 resource "aws_instance" "EC2-Bastion" {

     
     ami = data.aws_ami.ubuntu.id 
     
     instance_type = "t2.mirco"
     
     security_groups = [aws_security_group.public-sec-group.id]
     
     subnet_id = var.public-Subnets[0]
     
     tags = {
       name = "Bation-Host"
     }
       provisioner "local-exec" {
           command = "echo 'Bastion IP: ${self.public_ip}' >> ips.txt"
       
    }

     }


