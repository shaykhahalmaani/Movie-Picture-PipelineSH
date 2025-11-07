#!/bin/bash
set -e

echo "=========================================="
echo "Movie Application - Workspace Setup"
echo "=========================================="
echo ""

# Check for required tools
echo "Checking for required tools..."

if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform not found. Please install Terraform first."
    exit 1
fi
echo "✅ Terraform found"

if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found. Please install AWS CLI first."
    exit 1
fi
echo "✅ AWS CLI found"

if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl not found. Please install kubectl first."
    exit 1
fi
echo "✅ kubectl found"

echo ""
echo "All required tools are installed!"
echo ""

# Setup Terraform
echo "=========================================="
echo "Step 1: Setting up AWS Infrastructure"
echo "=========================================="
cd terraform

echo "Initializing Terraform..."
terraform init

echo ""
echo "Planning infrastructure..."
terraform plan

echo ""
read -p "Do you want to apply these changes? (yes/no): " apply_answer

if [ "$apply_answer" == "yes" ]; then
    echo "Applying Terraform configuration..."
    terraform apply -auto-approve
    
    echo ""
    echo "=========================================="
    echo "Infrastructure Created Successfully!"
    echo "=========================================="
    terraform output
    
    # Get cluster name and region
    CLUSTER_NAME=$(terraform output -raw cluster_name)
    AWS_REGION="us-east-1"
    
    echo ""
    echo "=========================================="
    echo "Step 2: Configuring kubectl"
    echo "=========================================="
    aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_REGION
    echo "✅ kubectl configured for EKS cluster"
    
    echo ""
    echo "=========================================="
    echo "Step 3: Creating GitHub Action User Keys"
    echo "=========================================="
    echo "Creating access keys for github-action-user..."
    
    # Create access key and store output
    ACCESS_KEY_OUTPUT=$(aws iam create-access-key --user-name github-action-user)
    
    AWS_ACCESS_KEY_ID=$(echo $ACCESS_KEY_OUTPUT | jq -r .AccessKey.AccessKeyId)
    AWS_SECRET_ACCESS_KEY=$(echo $ACCESS_KEY_OUTPUT | jq -r .AccessKey.SecretAccessKey)
    
    echo ""
    echo "✅ Access keys created!"
    echo ""
    echo "=========================================="
    echo "IMPORTANT: Save these credentials!"
    echo "=========================================="
    echo "AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID"
    echo "AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY"
    echo ""
    echo "Add these to your GitHub repository secrets:"
    echo "1. AWS_ACCESS_KEY_ID"
    echo "2. AWS_SECRET_ACCESS_KEY"
    echo "3. REACT_APP_MOVIE_API_URL (get backend LoadBalancer URL after first deployment)"
    echo ""
    
    cd ..
    
    echo "=========================================="
    echo "Step 4: Configuring EKS Permissions"
    echo "=========================================="
    
    if [ -f "init.sh" ]; then
        chmod +x init.sh
        ./init.sh
        echo "✅ EKS permissions configured"
    else
        echo "⚠️  init.sh not found, skipping permission configuration"
    fi
    
    echo ""
    echo "=========================================="
    echo "Setup Complete!"
    echo "=========================================="
    echo ""
    echo "Next steps:"
    echo "1. Add the AWS credentials to your GitHub Secrets"
    echo "2. Push your code to GitHub"
    echo "3. Create a pull request to test CI workflows"
    echo "4. Merge to main to deploy with CD workflows"
    echo "5. Get LoadBalancer URLs:"
    echo "   kubectl get services"
    echo "6. Add REACT_APP_MOVIE_API_URL secret with backend URL"
    echo ""
    
else
    echo "Setup cancelled. Run this script again when ready."
fi

