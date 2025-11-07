#!/bin/bash

# AWS Setup Script for Movie Picture Pipeline
# Run this script to set up all AWS resources

set -e  # Exit on error

echo "🚀 Starting AWS Setup..."

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found. Installing..."
    curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "/tmp/AWSCLIV2.pkg"
    sudo installer -pkg /tmp/AWSCLIV2.pkg -target /
    echo "✅ AWS CLI installed"
fi

# Check AWS credentials
echo "📋 Checking AWS credentials..."
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials not configured!"
    echo "Run: aws configure"
    echo "You'll need:"
    echo "  - AWS Access Key ID"
    echo "  - AWS Secret Access Key"
    echo "  - Default region (e.g., us-east-1)"
    exit 1
fi

echo "✅ AWS credentials configured"
REGION=$(aws configure get region || echo "us-east-1")
echo "📍 Using region: $REGION"

# Step 1: Create IAM User for GitHub Actions
echo ""
echo "👤 Step 1: Creating IAM user for GitHub Actions..."
USER_NAME="github-action-user"

# Check if user exists
if aws iam get-user --user-name $USER_NAME &> /dev/null; then
    echo "⚠️  User $USER_NAME already exists, skipping creation..."
else
    aws iam create-user --user-name $USER_NAME
    echo "✅ User created: $USER_NAME"
fi

# Attach policies
echo "📝 Attaching policies..."
aws iam attach-user-policy --user-name $USER_NAME --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess
aws iam attach-user-policy --user-name $USER_NAME --policy-arn arn:aws:iam::aws:policy/AmazonECRFullAccess
aws iam attach-user-policy --user-name $USER_NAME --policy-arn arn:aws:iam::aws:policy/AmazonEKSFullAccess
echo "✅ Policies attached"

# Create access keys
echo "🔑 Creating access keys..."
ACCESS_KEY_OUTPUT=$(aws iam create-access-key --user-name $USER_NAME)
ACCESS_KEY_ID=$(echo $ACCESS_KEY_OUTPUT | jq -r '.AccessKey.AccessKeyId')
SECRET_ACCESS_KEY=$(echo $ACCESS_KEY_OUTPUT | jq -r '.AccessKey.SecretAccessKey')

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "🔐 SAVE THESE CREDENTIALS FOR GITHUB SECRETS!"
echo "═══════════════════════════════════════════════════════════"
echo "AWS_ACCESS_KEY_ID: $ACCESS_KEY_ID"
echo "AWS_SECRET_ACCESS_KEY: $SECRET_ACCESS_KEY"
echo "═══════════════════════════════════════════════════════════"
echo ""
read -p "Press Enter after copying these credentials..."

# Step 2: Create ECR Repositories
echo ""
echo "📦 Step 2: Creating ECR repositories..."

# Create frontend repository
if aws ecr describe-repositories --repository-names movies-frontend --region $REGION &> /dev/null; then
    echo "⚠️  Repository movies-frontend already exists"
else
    aws ecr create-repository \
        --repository-name movies-frontend \
        --region $REGION \
        --image-scanning-configuration scanOnPush=true
    echo "✅ Repository created: movies-frontend"
fi

# Create backend repository
if aws ecr describe-repositories --repository-names movies-backend --region $REGION &> /dev/null; then
    echo "⚠️  Repository movies-backend already exists"
else
    aws ecr create-repository \
        --repository-name movies-backend \
        --region $REGION \
        --image-scanning-configuration scanOnPush=true
    echo "✅ Repository created: movies-backend"
fi

# Step 3: Create EKS Cluster
echo ""
echo "☸️  Step 3: Creating EKS cluster..."
CLUSTER_NAME="movie-picture-cluster"

# Check if cluster exists
if aws eks describe-cluster --name $CLUSTER_NAME --region $REGION &> /dev/null; then
    echo "⚠️  Cluster $CLUSTER_NAME already exists"
    echo "📍 Cluster ARN: $(aws eks describe-cluster --name $CLUSTER_NAME --region $REGION --query 'cluster.arn' --output text)"
else
    echo "⚠️  EKS cluster creation requires more setup..."
    echo "Creating cluster (this takes 10-15 minutes)..."
    
    # Create EKS service role
    ROLE_NAME="eks-service-role"
    if ! aws iam get-role --role-name $ROLE_NAME &> /dev/null; then
        echo "Creating EKS service role..."
        cat > /tmp/eks-role-trust-policy.json <<EOF
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
        aws iam create-role --role-name $ROLE_NAME --assume-role-policy-document file:///tmp/eks-role-trust-policy.json
        aws iam attach-role-policy --role-name $ROLE_NAME --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy
        echo "✅ EKS service role created"
    fi
    
    ROLE_ARN=$(aws iam get-role --role-name $ROLE_NAME --query 'Role.Arn' --output text)
    
    # Get default VPC and subnets
    VPC_ID=$(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query 'Vpcs[0].VpcId' --output text --region $REGION)
    SUBNETS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[*].SubnetId' --output text --region $REGION | tr '\t' ',')
    
    echo "Creating EKS cluster (this will take 10-15 minutes)..."
    aws eks create-cluster \
        --name $CLUSTER_NAME \
        --region $REGION \
        --role-arn $ROLE_ARN \
        --resources-vpc-config subnetIds=$SUBNETS \
        --version "1.28"
    
    echo "⏳ Waiting for cluster to be active..."
    aws eks wait cluster-active --name $CLUSTER_NAME --region $REGION
    echo "✅ Cluster created: $CLUSTER_NAME"
fi

# Create node group
echo ""
echo "🖥️  Creating node group..."
NODE_GROUP_NAME="movie-nodes"

# Get node group role
NODE_ROLE_NAME="eks-node-role"
if ! aws iam get-role --role-name $NODE_ROLE_NAME &> /dev/null; then
    echo "Creating node group role..."
    cat > /tmp/node-role-trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
    aws iam create-role --role-name $NODE_ROLE_NAME --assume-role-policy-document file:///tmp/node-role-trust-policy.json
    aws iam attach-role-policy --role-name $NODE_ROLE_NAME --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
    aws iam attach-role-policy --role-name $NODE_ROLE_NAME --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
    aws iam attach-role-policy --role-name $NODE_ROLE_NAME --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly
    echo "✅ Node role created"
fi

NODE_ROLE_ARN=$(aws iam get-role --role-name $NODE_ROLE_NAME --query 'Role.Arn' --output text)

if aws eks describe-nodegroup --cluster-name $CLUSTER_NAME --nodegroup-name $NODE_GROUP_NAME --region $REGION &> /dev/null; then
    echo "⚠️  Node group already exists"
else
    SUBNETS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[*].SubnetId' --output text --region $REGION | tr '\t' ' ')
    SUBNET_IDS=$(echo $SUBNETS | tr ' ' ',')
    
    echo "Creating node group (this takes 5-10 minutes)..."
    aws eks create-nodegroup \
        --cluster-name $CLUSTER_NAME \
        --nodegroup-name $NODE_GROUP_NAME \
        --node-role $NODE_ROLE_ARN \
        --subnets $SUBNET_IDS \
        --instance-types t3.small \
        --scaling-config minSize=2,maxSize=3,desiredSize=2 \
        --disk-size 20 \
        --region $REGION
    
    echo "⏳ Waiting for node group to be active..."
    aws eks wait nodegroup-active --cluster-name $CLUSTER_NAME --nodegroup-name $NODE_GROUP_NAME --region $REGION
    echo "✅ Node group created"
fi

# Summary
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "✅ AWS Setup Complete!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "📋 Add these to GitHub Secrets:"
echo "   https://github.com/shaykhahalmaani/Movie-Picture-PipelineSH/settings/secrets/actions"
echo ""
echo "   AWS_ACCESS_KEY_ID: $ACCESS_KEY_ID"
echo "   AWS_SECRET_ACCESS_KEY: $SECRET_ACCESS_KEY"
echo "   EKS_CLUSTER_NAME: $CLUSTER_NAME"
echo "   REACT_APP_MOVIE_API_URL: http://backend-service:5000 (optional)"
echo ""
echo "📍 Region: $REGION"
echo "☸️  Cluster: $CLUSTER_NAME"
echo ""
echo "🧪 Test kubectl:"
echo "   aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION"
echo "   kubectl get nodes"
echo ""
echo "═══════════════════════════════════════════════════════════"

