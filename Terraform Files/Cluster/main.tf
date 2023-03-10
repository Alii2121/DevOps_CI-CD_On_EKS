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


####################### Attach Policies to IAM Role ######################################



 ############################### This Policy is for EBS Add-on to Create EBS of PV K8s vloumes ##################
 resource "aws_iam_role_policy_attachment" "AmazonEKS_EBSCSI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role    = aws_iam_role.workernodes.name
 }

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
  version = "1.23"
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



##################### NODE GROUP ########################

## Node Group Role & Policies


resource "aws_iam_role" "workernodes" {
  name = "eks-node-group-example"
 
  assume_role_policy = jsonencode({
   Statement = [{
    Action = "sts:AssumeRole"
    Effect = "Allow"
    Principal = {
     Service = "ec2.amazonaws.com"
    }
   }]
   Version = "2012-10-17"
  })
 }
 
 resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role    = aws_iam_role.workernodes.name
 }
 
 resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role    = aws_iam_role.workernodes.name
 }
 
 ############################### This Policy is for EBS Add-on to Create EBS of PV K8s vloumes ##################
 resource "aws_iam_role_policy_attachment" "AmazonEKS_EBS_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role    = aws_iam_role.workernodes.name
 }


 ######## These Policies are used if you're going to use ECR #######
 resource "aws_iam_role_policy_attachment" "EC2InstanceProfileForImageBuilderECRContainerBuilds" {
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
  role    = aws_iam_role.workernodes.name
 }
 
 resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role    = aws_iam_role.workernodes.name
 }
 ##########################################################################


  resource "aws_eks_node_group" "worker-node-group" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  node_group_name = "ali-workernodes"
  node_role_arn  = aws_iam_role.workernodes.arn
  subnet_ids   = [
        var.private-Subnets[0],
        var.private-Subnets[1]
  ]
 
  instance_types = ["t3.medium"]
 
  scaling_config {
   desired_size = 2
   max_size   = 2
   min_size   = 1
  }
 
  depends_on = [
   aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
   aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
   aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
 }

