# AWS CLI Commands - Run These in Your Shell

## Prerequisites

1. **Install AWS CLI** (if not installed):
```bash
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "/tmp/AWSCLIV2.pkg"
sudo installer -pkg /tmp/AWSCLIV2.pkg -target /
```

2. **Configure AWS credentials:**
```bash
aws configure
```
Enter:
- AWS Access Key ID: (from your AWS account root user or IAM)
- AWS Secret Access Key: (from your AWS account)
- Default region: `us-east-1` (or your preferred region)
- Default output format: `json`

---

## Option 1: Run the Setup Script (Easiest)

```bash
cd /Users/faialradhi/Shaykha-project4
./setup-aws.sh
```

This will create everything automatically!

---

## Option 2: Run Commands Manually

### Step 1: Create IAM User

```bash
# Create user
aws iam create-user --user-name github-action-user

# Attach policies
aws iam attach-user-policy --user-name github-action-user --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess
aws iam attach-user-policy --user-name github-action-user --policy-arn arn:aws:iam::aws:policy/AmazonECRFullAccess
aws iam attach-user-policy --user-name github-action-user --policy-arn arn:aws:iam::aws:policy/AmazonEKSFullAccess

# Create access keys
aws iam create-access-key --user-name github-action-user
```

**Save the Access Key ID and Secret Access Key!**

---

### Step 2: Create ECR Repositories

```bash
# Set your region
export AWS_REGION=us-east-1

# Create frontend repository
aws ecr create-repository \
    --repository-name movies-frontend \
    --region $AWS_REGION \
    --image-scanning-configuration scanOnPush=true

# Create backend repository
aws ecr create-repository \
    --repository-name movies-backend \
    --region $AWS_REGION \
    --image-scanning-configuration scanOnPush=true
```

---

### Step 3: Create EKS Cluster

```bash
# Set variables
export CLUSTER_NAME=movie-picture-cluster
export AWS_REGION=us-east-1

# Create EKS service role
aws iam create-role --role-name eks-service-role \
    --assume-role-policy-document '{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {"Service": "eks.amazonaws.com"},
    "Action": "sts:AssumeRole"
  }]
}'

aws iam attach-role-policy --role-name eks-service-role \
    --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy

# Get role ARN
export ROLE_ARN=$(aws iam get-role --role-name eks-service-role --query 'Role.Arn' --output text)

# Get default VPC and subnets
export VPC_ID=$(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query 'Vpcs[0].VpcId' --output text --region $AWS_REGION)
export SUBNETS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[*].SubnetId' --output text --region $AWS_REGION | tr '\t' ',')

# Create cluster
aws eks create-cluster \
    --name $CLUSTER_NAME \
    --region $AWS_REGION \
    --role-arn $ROLE_ARN \
    --resources-vpc-config subnetIds=$SUBNETS \
    --version "1.28"

# Wait for cluster (takes 10-15 minutes)
aws eks wait cluster-active --name $CLUSTER_NAME --region $AWS_REGION
```

---

### Step 4: Create Node Group

```bash
# Create node role
aws iam create-role --role-name eks-node-role \
    --assume-role-policy-document '{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {"Service": "ec2.amazonaws.com"},
    "Action": "sts:AssumeRole"
  }]
}'

aws iam attach-role-policy --role-name eks-node-role --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
aws iam attach-role-policy --role-name eks-node-role --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
aws iam attach-role-policy --role-name eks-node-role --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly

export NODE_ROLE_ARN=$(aws iam get-role --role-name eks-node-role --query 'Role.Arn' --output text)

# Create node group
aws eks create-nodegroup \
    --cluster-name $CLUSTER_NAME \
    --nodegroup-name movie-nodes \
    --node-role $NODE_ROLE_ARN \
    --subnets $SUBNETS \
    --instance-types t3.small \
    --scaling-config minSize=2,maxSize=3,desiredSize=2 \
    --disk-size 20 \
    --region $AWS_REGION

# Wait for node group (takes 5-10 minutes)
aws eks wait nodegroup-active --cluster-name $CLUSTER_NAME --nodegroup-name movie-nodes --region $AWS_REGION
```

---

## Verify Setup

```bash
# Check IAM user
aws iam get-user --user-name github-action-user

# Check ECR repositories
aws ecr describe-repositories --repository-names movies-frontend movies-backend

# Check EKS cluster
aws eks describe-cluster --name movie-picture-cluster

# Configure kubectl
aws eks update-kubeconfig --name movie-picture-cluster --region us-east-1

# Test kubectl
kubectl get nodes
```

---

## Get Your Credentials

After running Step 1, you'll get output like:
```json
{
    "AccessKey": {
        "AccessKeyId": "AKIA...",
        "SecretAccessKey": "xxxxx...",
        "Status": "Active"
    }
}
```

**Save these for GitHub Secrets!**

---

## Add to GitHub

Go to: https://github.com/shaykhahalmaani/Movie-Picture-PipelineSH/settings/secrets/actions

Add:
- `AWS_ACCESS_KEY_ID` = Your access key from Step 1
- `AWS_SECRET_ACCESS_KEY` = Your secret key from Step 1
- `EKS_CLUSTER_NAME` = `movie-picture-cluster`
- `REACT_APP_MOVIE_API_URL` = `http://backend-service:5000` (optional)

---

## Quick One-Liner Script

Or run everything at once:

```bash
cd /Users/faialradhi/Shaykha-project4 && ./setup-aws.sh
```

