# Terraform Infrastructure Setup

This directory contains Terraform configuration files to set up the AWS infrastructure for the Movie Application CI/CD pipeline.

## Infrastructure Components

The Terraform configuration creates the following AWS resources:

### Networking
- VPC with DNS support
- Internet Gateway
- Public and Private Subnets
- Route Tables and Associations
- VPC Endpoints (optional, for private clusters)

### Container Registry
- ECR Repositories for frontend and backend images

### Kubernetes Cluster
- EKS Cluster
- EKS Node Group with auto-scaling
- IAM Roles and Policies for EKS

### CI/CD Support
- CodeBuild Project
- IAM User for GitHub Actions
- IAM Policies for GitHub Actions

## Prerequisites

Before running Terraform, ensure you have:

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** installed (version >= 1.3.9)
3. **Appropriate AWS Permissions** to create:
   - VPC resources
   - EKS clusters
   - ECR repositories
   - IAM roles and users

## Configuration Variables

The following variables can be customized in `variables.tf`:

- `k8s_version`: Kubernetes version (default: "1.28")
- `enable_private`: Enable private cluster endpoints (default: false)
- `public_az`: Availability zone for public subnet (default: "a")
- `private_az`: Availability zone for private subnet (default: "b")

## Usage

### 1. Initialize Terraform

```bash
cd setup/terraform
terraform init
```

### 2. Review the Plan

```bash
terraform plan
```

### 3. Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted to confirm the creation of resources.

### 4. Get Outputs

After successful deployment, retrieve important information:

```bash
terraform output
```

This will display:
- Frontend ECR repository URL
- Backend ECR repository URL
- EKS cluster name
- EKS cluster version
- GitHub Action user ARN

## Outputs

The Terraform configuration provides the following outputs:

- `frontend_ecr`: URL for the frontend ECR repository
- `backend_ecr`: URL for the backend ECR repository
- `cluster_name`: Name of the EKS cluster
- `cluster_version`: Kubernetes version of the EKS cluster
- `github_action_user_arn`: ARN of the IAM user for GitHub Actions

## Post-Deployment Steps

After Terraform completes:

1. **Configure kubectl**:
   ```bash
   aws eks update-kubeconfig --name cluster --region us-east-1
   ```

2. **Create Access Keys** for GitHub Actions user:
   ```bash
   aws iam create-access-key --user-name github-action-user
   ```

3. **Run the init script** to configure permissions:
   ```bash
   cd ../
   ./init.sh
   ```

4. **Add GitHub Secrets**:
   - AWS_ACCESS_KEY_ID
   - AWS_SECRET_ACCESS_KEY
   - REACT_APP_MOVIE_API_URL

## Cleanup

To destroy all resources created by Terraform:

```bash
terraform destroy
```

**Warning**: This will delete all resources, including the EKS cluster and ECR repositories.

## Cost Considerations

Running this infrastructure will incur AWS costs, primarily from:
- EKS cluster control plane (~$0.10/hour)
- EC2 instances in the node group
- Data transfer costs
- ECR storage

To minimize costs:
- Delete resources when not in use
- Use smaller instance types for development
- Monitor your AWS billing dashboard

## Troubleshooting

### Availability Zone Errors

If you encounter errors about availability zones, modify the `public_az` or `private_az` variables:

```bash
terraform apply -var="public_az=c" -var="private_az=d"
```

### EKS Cluster Creation Timeout

EKS cluster creation can take 10-15 minutes. If it times out, check the AWS Console for the cluster status.

### IAM Permission Errors

Ensure your AWS credentials have sufficient permissions to create all required resources.

