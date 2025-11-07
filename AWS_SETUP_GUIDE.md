# AWS Setup Guide - Complete Instructions

## Overview
You need to set up:
1. IAM User for GitHub Actions
2. ECR Repositories (for Docker images)
3. EKS Cluster (for Kubernetes)
4. Get AWS Credentials

## Step 1: Create IAM User for GitHub Actions

### 1.1 Go to IAM Console
1. Sign in to AWS Console: https://console.aws.amazon.com
2. Search for "IAM" in the top search bar
3. Click on **IAM**

### 1.2 Create New User
1. Click **Users** (left sidebar)
2. Click **Create user** button
3. **User name**: `github-action-user`
4. Click **Next**

### 1.3 Set Permissions
1. Select **Attach policies directly**
2. Check these policies:
   - ✅ `AmazonEC2FullAccess`
   - ✅ `AmazonECRFullAccess`
   - ✅ `AmazonEKSFullAccess`
   - ✅ `IAMFullAccess` (for Terraform setup)
3. Click **Next**
4. Click **Create user**

### 1.4 Create Access Keys
1. Click on the user `github-action-user`
2. Go to **Security credentials** tab
3. Scroll to **Access keys** section
4. Click **Create access key**
5. Select **Application running outside AWS**
6. Click **Next**
7. Click **Create access key**
8. **⚠️ IMPORTANT**: Copy both:
   - **Access key ID** (starts with `AKIA...`)
   - **Secret access key** (click "Show" to reveal)
   - Save these safely - you'll need them for GitHub Secrets!

## Step 2: Create ECR Repositories

### 2.1 Go to ECR Console
1. In AWS Console, search for "ECR"
2. Click **Elastic Container Registry**

### 2.2 Create Frontend Repository
1. Click **Create repository**
2. **Visibility**: Private
3. **Repository name**: `movies-frontend`
4. Leave other settings as default
5. Click **Create repository**
6. Note the **URI** (e.g., `123456789012.dkr.ecr.us-east-1.amazonaws.com/movies-frontend`)

### 2.3 Create Backend Repository
1. Click **Create repository** again
2. **Visibility**: Private
3. **Repository name**: `movies-backend`
4. Leave other settings as default
5. Click **Create repository**
6. Note the **URI**

## Step 3: Create EKS Cluster

### Option A: Using Terraform (Recommended - Based on Project Instructions)

1. **Install Terraform:**
   ```bash
   git clone https://github.com/tfutils/tfenv.git ~/.tfenv
   export PATH="$HOME/.tfenv/bin:$PATH"
   source ~/.bashrc
   tfenv install 1.3.9
   tfenv use 1.3.9
   ```

2. **Create Administrator User:**
   - Go to IAM → Users → Create user
   - Name: `terraform-admin`
   - Attach policy: `AdministratorAccess`
   - Create access key for this user
   - Save the credentials

3. **Set Environment Variables:**
   ```bash
   export AWS_ACCESS_KEY_ID=YOUR_ADMIN_ACCESS_KEY
   export AWS_SECRET_ACCESS_KEY=YOUR_ADMIN_SECRET_KEY
   ```

4. **Run Terraform:**
   ```bash
   cd setup/terraform
   terraform init
   terraform apply
   # Type 'yes' when prompted
   ```

5. **Get Outputs:**
   ```bash
   terraform output
   ```
   - Note the `cluster_name` and `region`

6. **Run init.sh:**
   ```bash
   cd setup
   ./init.sh
   ```
   This adds the GitHub Actions user to Kubernetes.

### Option B: Using AWS Console (Manual)

1. **Go to EKS Console:**
   - Search for "EKS" in AWS Console
   - Click **Elastic Kubernetes Service**

2. **Create Cluster:**
   - Click **Create cluster**
   - **Cluster name**: `movie-picture-cluster`
   - **Kubernetes version**: Latest (1.28 or 1.29)
   - **Region**: Choose your region (e.g., `us-east-1`)

3. **Configure Networking:**
   - Select or create VPC
   - Select subnets
   - Keep default settings

4. **Configure Cluster Service Role:**
   - Create new IAM role if needed
   - Role should have EKS permissions

5. **Add Node Group:**
   - **Node group name**: `movie-picture-nodes`
   - **Instance type**: `t3.medium` (or `t3.small` for testing)
   - **Node count**: 2-3 nodes
   - Click **Create**

6. **Wait for Creation:**
   - Takes 10-15 minutes
   - Note the cluster name and region

## Step 4: Get Your AWS Credentials Summary

After setup, you'll have:

### For GitHub Secrets:
1. **AWS_ACCESS_KEY_ID**: From `github-action-user` (Step 1.4)
   - Format: `AKIA...`

2. **AWS_SECRET_ACCESS_KEY**: From `github-action-user` (Step 1.4)
   - Format: Long string

3. **EKS_CLUSTER_NAME**: 
   - If using Terraform: From `terraform output`
   - If manual: The name you gave (e.g., `movie-picture-cluster`)

4. **REACT_APP_MOVIE_API_URL**: (Optional)
   - Default: `http://backend-service:5000`
   - Or use your backend service URL

### AWS Region:
- Note your region (e.g., `us-east-1`, `us-west-2`)
- You may need to update workflows if not using `us-east-1`

## Step 5: Add Secrets to GitHub

1. Go to: https://github.com/shaykhahalmaani/Movie-Picture-PipelineSH
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret** for each:

   **Secret 1:**
   - Name: `AWS_ACCESS_KEY_ID`
   - Value: Your access key from Step 1.4

   **Secret 2:**
   - Name: `AWS_SECRET_ACCESS_KEY`
   - Value: Your secret key from Step 1.4

   **Secret 3:**
   - Name: `EKS_CLUSTER_NAME`
   - Value: Your cluster name (e.g., `movie-picture-cluster`)

   **Secret 4:** (Optional)
   - Name: `REACT_APP_MOVIE_API_URL`
   - Value: `http://backend-service:5000`

## Step 6: Update Workflow Region (If Needed)

If your AWS region is NOT `us-east-1`, update the workflows:

1. Edit `.github/workflows/frontend-cd.yaml`
2. Change line with `AWS_REGION: us-east-1` to your region
3. Do the same for `backend-cd.yaml`

## Step 7: Verify Setup

1. **Check ECR Repositories:**
   - Go to ECR console
   - Verify `movies-frontend` and `movies-backend` exist

2. **Check EKS Cluster:**
   - Go to EKS console
   - Verify cluster is "Active"
   - Note the cluster name

3. **Test kubectl:**
   ```bash
   aws eks update-kubeconfig --name YOUR_CLUSTER_NAME --region YOUR_REGION
   kubectl get nodes
   ```
   Should show your cluster nodes

## Cost Estimate

- **EKS Cluster**: ~$0.10/hour ($72/month)
- **EC2 Nodes**: Depends on instance type
  - `t3.small`: ~$0.02/hour
  - `t3.medium`: ~$0.04/hour
- **ECR**: Storage costs (minimal)
- **Total**: ~$100-200/month for testing

⚠️ **Important**: Destroy resources when done to avoid charges!

## Troubleshooting

### "Access Denied" Errors
- Verify IAM user has correct policies
- Check access keys are correct
- Ensure user has ECR and EKS permissions

### Cannot Create EKS Cluster
- May need to wait for account verification
- Check service quotas
- Verify IAM permissions

### Terraform Errors
- Ensure you're using the admin user credentials
- Check Terraform version (1.3.9)
- Verify AWS credentials are set

## Next Steps After Setup

1. ✅ Add secrets to GitHub
2. ✅ Test CI pipeline (create a PR)
3. ✅ Test CD pipeline (merge to main)
4. ✅ Verify deployment on EKS
5. ✅ Submit your project!

