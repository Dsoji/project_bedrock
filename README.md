# PROJECT BEDROCK
## ✨ Deployment and Architecture of Innovate Mart's E-commerce startup "Project Bedrock

## IAC 


### Created an IAM user 'Terraform' with Admin access and access key in the console and configured it on the CLI.
```bash
aws configure
# You'll be prompted to enter:
# AWS Access Key ID [None]: your-access-key
# AWS Secret Access Key [None]: your-secret-key
# Default region name [None]: eu-west-2
# Default output format [None]: json
```

### Provisioned the following AWS resources:
### - VPC with CIDR 10.0.0.0/16
### - Subnets (2 Public and 2 Private Subnets across eu-west-2a and eu-west-2b)
### - Route Tables with proper internet gateway routing
### - Internet Gateway
### - NAT Gateway was not provisioned due to cost considerations
### - Elastic Kubernetes Service(EKS) and Nodes in the Public subnets for internet access
#### Roles attached:
#### 1. AmazonEC2ContainerRegistryReadOnly
#### 2. AmazonEKSWorkerNodePolicy
#### 3. AmazonEKS_CNI_Policy


### Ran the following commands to apply these changes to AWS:
```bash
# Create terraform.tfvars file
echo 'aws_region = "eu-west-2"' > terraform.tfvars

# Initialize and apply
terraform init
terraform plan
terraform apply
```

### ⚠️ Important Notes:
- **Instance Type**: Changed from t3.medium to t3.small (Free Tier eligible)
- **Subnet Configuration**: Nodes deployed in public subnets for internet access
- **Availability Zones**: Subnets distributed across eu-west-2a and eu-west-2b

## ✨ Kubernetes Configuration
### Configured Kubernetes
`aws eks update-kubeconfig --name  project-bedrock-eks  --region eu-west-2`
### Ran the following commands to test 
`
kubectl get nodes
`
### Deployed the containers 
`
kubectl apply -f https://github.com/aws-containers/retail-store-sample-app/releases/latest/download/kubernetes.yaml
`
### Confirmed it was running successfully
`
kubectl get pods
`

### Got the deployed ui's EXTERNAL-IP
`ui     LoadBalancer   172.20.113.0   a3b2a86fca4af4edabecd2e5bf5c66ec-882766964.eu-west-2.elb.amazonaws.com   80:31361/TCP   3m52s
`

## ✨ IAM (Identity and Access Management)

### Created an IAM user "eks_dev_" in the console to access the EKS cluster with JSON Policy:
`
{
    "Version": "2012-10-17",   
    "Statement": [
        {
            "Sid": "Statement1",
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
            ], <br>
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:GetRole",
                "iam:ListAttachedRolePolicies"
            ], <br>
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
            ],<br>
            "Resource": "*"
        }
    ]
}
`

### ✨Created a Cluster role and Cluster role binding "eks-developer.yaml" for the developer (eks_dev_) to be able to access the following:
`
    - pods
    - pods/log
    - pods/status
    - services
    - endpoints
    - persistentvolumeclaims
    - persistentvolumes
    - nodes
    - namespaces
    - configmaps
    - secrets
    - events
`
### Added the aws IAM user to the kube-configuration
```bash
# Apply RBAC configuration
kubectl apply -f eks-developer.yaml

# Add user to EKS cluster
kubectl patch configmap/aws-auth -n kube-system --patch '{
  "data": {
    "mapUsers": "|\n- userarn: arn:aws:iam::103794580682:user/eks_dev_\n  username: eks_dev_\n  groups:\n  - system:masters\n"
  }
}'
```

### ✅ Developer Access Setup Complete
The `eks_dev_` user now has full access to the EKS cluster with the following permissions:
- **Kubernetes Resources**: pods, services, deployments, configmaps, secrets, etc.
- **System Access**: system:masters group (full cluster access)
- **AWS Permissions**: EKS, EC2, and IAM read access
## 🔧 Troubleshooting

### Common Issues and Solutions:

1. **EKS Node Group Creation Fails**
   - **Issue**: "Instances failed to join the kubernetes cluster"
   - **Solution**: Ensure subnets have proper internet gateway routing and use Free Tier eligible instance types (t3.small)

2. **Free Tier Instance Type Error**
   - **Issue**: "The specified instance type is not eligible for Free Tier"
   - **Solution**: Use t3.small instead of t3.medium for Free Tier compatibility

3. **Subnet Availability Zone Error**
   - **Issue**: "Subnets specified must be in at least two different AZs"
   - **Solution**: Ensure subnets are distributed across multiple availability zones

4. **Developer Access Issues**
   - **Issue**: Developer cannot access EKS cluster
   - **Solution**: Verify IAM user has correct permissions and is added to aws-auth configmap

## 🚀 Next Steps

### For Developers:
1. Configure AWS CLI with `eks_dev_` credentials
2. Connect to cluster: `aws eks update-kubeconfig --name project-bedrock-eks --region eu-west-2`
3. Test access: `kubectl get nodes`

### For Deployment:
1. Deploy sample application: `kubectl apply -f https://github.com/aws-containers/retail-store-sample-app/releases/latest/download/kubernetes.yaml`
2. Check status: `kubectl get pods`
3. Get external IP: `kubectl get services`

## ✨ CI/CD WITH GITHUB ACTIONS
### Added a workflow file that is triggered when changes are pushed to the feature branch and runs "terraform plan"; while a merge triggers the "terraform apply" command. This is the concept of GitFlow.
# project_bedrock
