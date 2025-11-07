# Troubleshooting - Why It's Not Working

Let's check each step to find the problem:

## Step 1: Check if Cluster Exists

```bash
# List all clusters in eu-north-1
aws eks list-clusters --region eu-north-1

# If empty, check other regions
aws eks list-clusters --region us-east-1
aws eks list-clusters --region eu-west-1
```

**What to check:**
- Does the cluster exist?
- What region is it in?
- What's the exact name?

---

## Step 2: Check if CD Pipeline Ran

1. Go to: **https://github.com/shaykhahalmaani/Movie-Picture-PipelineSH/actions**
2. Look for:
   - **Frontend Continuous Deployment** - Did it run? Status?
   - **Backend Continuous Deployment** - Did it run? Status?

**If pipelines haven't run:**
- You need to merge a PR to `main` branch first
- Or push directly to `main`

**If pipelines failed:**
- Click on the failed workflow
- Check the error messages
- Common issues:
  - Wrong cluster name
  - Wrong region
  - ECR login failed
  - Kubernetes connection failed

---

## Step 3: Check if Deployments Exist

```bash
# Configure kubectl (use correct region)
aws eks update-kubeconfig --name movie-picture-cluster --region eu-north-1

# Check deployments
kubectl get deployments

# Check services
kubectl get services

# Check pods
kubectl get pods
```

**What you should see:**
- `backend-deployment` and `frontend-deployment` (if deployed)
- `backend-service` and `frontend-service` (if deployed)
- Pods with STATUS "Running"

**If you see "No resources found":**
- Nothing has been deployed yet
- CD pipeline needs to run first

---

## Step 4: Check ECR Repositories

1. Go to AWS Console → ECR
2. Check if repositories exist:
   - `movies-frontend`
   - `movies-backend`
3. Click on each repository
4. Check if there are any images

**If no images:**
- CD pipeline hasn't pushed images yet
- Pipeline might have failed at build step

---

## Common Problems & Solutions

### Problem 1: "Cluster not found"
**Solution:**
- Check AWS Console → EKS
- Find the actual cluster name
- Update GitHub secret `EKS_CLUSTER_NAME`
- Update workflows if region is different

### Problem 2: "No deployments found"
**Solution:**
- CD pipeline hasn't run or failed
- Merge PR to `main` branch
- Check GitHub Actions for errors

### Problem 3: "Port-forward works but stops"
**Solution:**
- Port-forward is temporary
- Use LoadBalancer external IP instead
- Or keep port-forward running in background

### Problem 4: "Pipeline fails at ECR login"
**Solution:**
- Check AWS credentials in GitHub Secrets
- Verify credentials have ECR permissions
- Check region matches

### Problem 5: "Pipeline fails at kubectl apply"
**Solution:**
- Check EKS cluster is "Active"
- Verify cluster name matches exactly
- Check node group is "Active"
- Verify kubectl can connect

---

## Quick Diagnostic Commands

Run these to see what's wrong:

```bash
# 1. Check cluster exists
aws eks list-clusters --region eu-north-1

# 2. Check cluster status (if exists)
aws eks describe-cluster --name movie-picture-cluster --region eu-north-1 --query 'cluster.status'

# 3. Configure kubectl
aws eks update-kubeconfig --name movie-picture-cluster --region eu-north-1

# 4. Check if anything is deployed
kubectl get all

# 5. Check GitHub Actions
# Go to: https://github.com/shaykhahalmaani/Movie-Picture-PipelineSH/actions
```

---

## Tell Me What You See

Please check and tell me:

1. **AWS Console → EKS:**
   - Do you see `movie-picture-cluster`?
   - What status? (Active, Creating, Failed)
   - What region?

2. **GitHub Actions:**
   - Go to Actions tab
   - Do you see any CD pipelines that ran?
   - What status? (Green ✅ or Red ❌)

3. **ECR:**
   - Go to AWS Console → ECR
   - Do repositories exist?
   - Are there any images?

4. **kubectl:**
   - Run: `kubectl get all`
   - What does it show?

Then I can help you fix the specific problem!

