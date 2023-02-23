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


#---------------------------------------------------------------------------
# EC2 Role to access EKS Cluster
#----------------------------------------------------------------------------

resource "aws_iam_role" "eks-ec2-role" {
  name = "eks-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks-policy-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-ec2-role.name
}

resource "aws_iam_role_policy_attachment" "eks-node-policy-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-ec2-role.name
}

resource "aws_iam_role_policy_attachment" "eks-cni-policy-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-ec2-role.name
}



resource "aws_iam_instance_profile" "ec2_kubectl_profile" {
  name = "ec2-eks-profile"
  role = aws_iam_role.eks-ec2-role.name
}
#-------------------------------------------------------------------------------







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
     
     instance_type = "t2.micro"
     
     security_groups = [aws_security_group.public-sec-group.id]
     
     subnet_id = var.public-Subnets[0]
     
     key_name = "ansible"
     
     iam_instance_profile = aws_iam_instance_profile.ec2_kubectl_profile.name
   
    # lifecycle {
    # prevent_destroy = true
    #  }
     tags = {
       name = "Bation-Host"
     }
       provisioner "local-exec" {
           command = "echo 'Bastion IP: ${self.public_ip}' >> ips.txt"
       
    }

     }


