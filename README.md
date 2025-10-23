# Project Bedrock

A comprehensive AWS EKS infrastructure deployment for Innovate Mart's e-commerce platform, built with Terraform and Kubernetes.

## Overview

This project implements a production-ready containerized application infrastructure on AWS, featuring an Elastic Kubernetes Service (EKS) cluster with proper networking, security, and access management.

## Architecture

The infrastructure consists of:

- **VPC**: Custom virtual private cloud with CIDR 10.0.0.0/16
- **Networking**: Multi-AZ subnet configuration across eu-west-2a and eu-west-2b
- **Compute**: EKS cluster with managed node groups
- **Security**: IAM roles, security groups, and RBAC policies
- **Access Control**: Developer access management with granular permissions

## Prerequisites

Before deploying this infrastructure, ensure you have:

- AWS CLI configured with appropriate permissions
- Terraform installed (version 1.0+)
- kubectl installed for Kubernetes management
- An AWS account with sufficient permissions

## Quick Start

### 1. AWS Configuration

Configure your AWS credentials:

```bash
aws configure
```

Enter your AWS Access Key ID, Secret Access Key, and set the region to `eu-west-2`.

### 2. Infrastructure Deployment

Deploy the infrastructure using Terraform:

```bash
# Initialize Terraform
terraform init

# Create variables file
echo 'aws_region = "eu-west-2"' > terraform.tfvars

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

### 3. Kubernetes Setup

Connect to your EKS cluster:

```bash
aws eks update-kubeconfig --name project-bedrock-eks --region eu-west-2
```

Verify the cluster is accessible:

```bash
kubectl get nodes
```

## Infrastructure Components

### Networking

The VPC is configured with:
- **Public Subnets**: 10.0.32.0/20 (eu-west-2a), 10.0.16.0/20 (eu-west-2b)
- **Private Subnets**: 10.0.128.0/20 (eu-west-2a), 10.0.144.0/20 (eu-west-2b)
- **Internet Gateway**: For public subnet internet access
- **Route Tables**: Properly configured for traffic routing

### Compute Resources

- **EKS Cluster**: project-bedrock-eks (version 1.33)
- **Node Group**: t3.small instances (Free Tier eligible)
- **Auto Scaling**: 1-1 node configuration
- **Subnet Placement**: Public subnets for internet connectivity

### Security

- **IAM Roles**: EKS cluster and node group roles
- **Security Groups**: EKS-managed security groups
- **RBAC**: Kubernetes role-based access control

## Developer Access

### Setting Up Developer Access

1. **Create IAM User**: Create `eks_dev_` user in AWS Console
2. **Attach Policy**: Apply the following IAM policy:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "EKSReadAccess",
            "Effect": "Allow",
            "Action": [
                "eks:DescribeCluster",
                "eks:ListClusters",
                "eks:DescribeNodegroup",
                "eks:ListNodegroups",
                "eks:DescribeUpdate",
                "eks:ListUpdates",
                "eks:DescribeFargateProfile",
                "eks:ListFargateProfiles",
                "eks:DescribeAddon",
                "eks:ListAddons",
                "eks:DescribeAddonVersions",
                "eks:ListIdentityProviderConfigs",
                "eks:DescribeIdentityProviderConfig"
            ],
            "Resource": ["*"]
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:GetRole",
                "iam:ListAttachedRolePolicies"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "ec2:DescribeImages",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVpcs"
            ],
            "Resource": "*"
        }
    ]
}
```

3. **Apply Kubernetes RBAC**:

```bash
kubectl apply -f eks-developer.yaml
```

4. **Add User to Cluster**:

```bash
kubectl patch configmap/aws-auth -n kube-system --patch '{
  "data": {
    "mapUsers": "|\n- userarn: arn:aws:iam::103794580682:user/eks_dev_\n  username: eks_dev_\n  groups:\n  - system:masters\n"
  }
}'
```

### Developer Permissions

The `eks_dev_` user has access to:
- Kubernetes resources (pods, services, deployments, configmaps, secrets)
- Cluster monitoring and management
- Full system access via system:masters group

## Application Deployment

Deploy a sample e-commerce application:

```bash
kubectl apply -f https://github.com/aws-containers/retail-store-sample-app/releases/latest/download/kubernetes.yaml
```

Check deployment status:

```bash
kubectl get pods
kubectl get services
```

## Configuration Details

### Instance Configuration

- **Instance Type**: t3.small (Free Tier eligible)
- **AMI**: Amazon Linux 2023
- **Storage**: 20GB EBS volumes
- **Networking**: Public IP assignment enabled

### Cost Optimization

- Free Tier eligible instance types
- No NAT Gateway (cost consideration)
- Single node configuration for development

## Troubleshooting

### Common Issues

**Node Group Creation Fails**
- Ensure subnets have internet gateway routing
- Verify instance type is Free Tier eligible
- Check security group configurations

**Developer Access Denied**
- Verify IAM user has correct permissions
- Confirm user is added to aws-auth configmap
- Check AWS CLI configuration

**Cluster Connectivity Issues**
- Verify kubectl context is correct
- Check EKS cluster endpoint accessibility
- Confirm security group rules

## File Structure

```
project-bedrock/
├── main.tf                 # Terraform provider configuration
├── vpc.tf                  # VPC and networking resources
├── eks.tf                  # EKS cluster and node groups
├── variable.tf             # Terraform variables
├── eks-developer.yaml      # Kubernetes RBAC configuration
├── terraform.tfvars        # Variable values (not in git)
└── README.md              # This file
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the infrastructure deployment
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For issues and questions:
- Check the troubleshooting section
- Review AWS EKS documentation
- Open an issue in the repository