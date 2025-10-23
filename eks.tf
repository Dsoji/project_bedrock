resource "aws_eks_cluster" "project-bedrock-eks" {
    name     = "project-bedrock-eks"
    role_arn = aws_iam_role.project-bedrock-eks-role.arn
    version = 1.33

    vpc_config {
        subnet_ids = [
            aws_subnet.project-bedrock-subnet-public1.id,
            aws_subnet.project-bedrock-subnet-public2.id,
            aws_subnet.project-bedrock-subnet-private1.id,
            aws_subnet.project-bedrock-subnet-private2.id
        ]
    }

    depends_on = [aws_iam_role_policy_attachment.project-bedrock-eks-policy-AmazonEKSClusterPolicy]
  
}

resource "aws_iam_role_policy_attachment" "project-bedrock-eks-node-policy-AmazonEKS_CNI_Policy" {
    role       = aws_iam_role.project-bedrock-eks-node-role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "project-bedrock-eks-node-policy-AmazonEC2ContainerRegistryReadOnly" {
    role       = aws_iam_role.project-bedrock-eks-node-role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role" "project-bedrock-eks-role" {
    name = "project-bedrock-eks-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "eks.amazonaws.com"
                }
            },
        ]
    })
}

resource "aws_iam_role_policy_attachment" "project-bedrock-eks-policy-AmazonEKSClusterPolicy" {
    role       = aws_iam_role.project-bedrock-eks-role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_node_group" "project-bedrock-eks-node-group" {
    cluster_name    = aws_eks_cluster.project-bedrock-eks.name
    node_group_name = "project-bedrock-eks-node-group"
    node_role_arn   = aws_iam_role.project-bedrock-eks-node-role.arn
    subnet_ids      = [
        aws_subnet.project-bedrock-subnet-public1.id,
        aws_subnet.project-bedrock-subnet-public2.id
    ]
    scaling_config {
        desired_size = 1
        max_size     = 1
        min_size     = 1
    }
    instance_types = ["t3.small"]

    depends_on = [aws_iam_role_policy_attachment.project-bedrock-eks-node-policy-AmazonEKSWorkerNodePolicy, aws_iam_role_policy_attachment.project-bedrock-eks-node-policy-AmazonEKS_CNI_Policy, aws_iam_role_policy_attachment.project-bedrock-eks-node-policy-AmazonEC2ContainerRegistryReadOnly]
}

resource "aws_iam_role" "project-bedrock-eks-node-role" {
    name = "project-bedrock-eks-node-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            },
        ]
    })
}

resource "aws_iam_role_policy_attachment" "project-bedrock-eks-node-policy-AmazonEKSWorkerNodePolicy" {
    role       = aws_iam_role.project-bedrock-eks-node-role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

