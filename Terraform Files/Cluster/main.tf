############### IAM Role For The Cluster #################

resource "aws_iam_role" "eks-iam-role" {
 name = "Ali-Marawan-eks-iam-role"

 path = "/"

 assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
  {
   "Effect": "Allow",
   "Principal": {
    "Service": "eks.amazonaws.com"
   },
   "Action": "sts:AssumeRole"
  }
 ]
}
EOF

}


####################### Attach Policies to IAM Role ################

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
 role    = aws_iam_role.eks-iam-role.name
}
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly-EKS" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
 role    = aws_iam_role.eks-iam-role.name
} ## In case you use ECR 

####################### Secure EKS Cluster #######################

resource "aws_eks_cluster" "eks_cluster" {
  name     = "ali-eks-cluster"
  role_arn = aws_iam_role.eks-iam-role.arn

  vpc_config {
    subnet_ids = [
        var.private-Subnets[0],
        var.private-Subnets[1]

    ]

    endpoint_private_access = true
    endpoint_public_access  = false
  }

  depends_on = [
    aws_iam_role.eks-iam-role
  ]
}

