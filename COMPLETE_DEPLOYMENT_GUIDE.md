# Complete Deployment Guide - Step by Step

## Step 1: Verify EKS Cluster in AWS Console

### 1.1 Go to EKS Console
1. Open: **https://console.aws.amazon.com**
2. Sign in
3. In search bar (top), type: **EKS**
4. Click **"Elastic Kubernetes Service"**

### 1.2 Check Cluster Status
1. Look for cluster: **`movie-picture-cluster`**
2. Check the **Status** column:
   - ✅ **"Active"** = Good, ready to use
   - ⏳ **"Creating"** = Wait 10-15 minutes
   - ❌ **"Failed"** = Something went wrong

### 1.3 Check Node Group
1. Click on cluster name: **`movie-picture-cluster`**
2. Click **"Compute"** tab
3. Look for node group: **`movie-nodes`**
4. Check status:
   - ✅ **"Active"** = Good
   - ⏳ **"Creating"** = Wait 5-10 minutes

**✅ If both are "Active", proceed to Step 2!**

---

## Step 2: Deploy Applications - Merge PR to Main

### Option A: Merge Your Test PR (Recommended)

1. **Go to GitHub:**
   - https://github.com/shaykhahalmaani/Movie-Picture-PipelineSH

2. **Go to Pull Requests:**
   - Click **"Pull requests"** tab
   - Find your test PR (or create one if you don't have one)

3. **Merge the PR:**
   - Click **"Merge pull request"** button
   - Click **"Confirm merge"**
   - This triggers the CD pipeline!

### Option B: Push Directly to Main

If you want to push directly:

```bash
cd /Users/faialradhi/Shaykha-project4

# Switch to main branch
git checkout main

# Make a small change
echo "# Deployment" >> DEPLOY.md
git add DEPLOY.md
git commit -m "Trigger CD pipeline"
git push origin main
```

---

## Step 3: Watch CD Pipeline in GitHub Actions

### 3.1 Go to Actions Tab
1. Go to: **https://github.com/shaykhahalmaani/Movie-Picture-PipelineSH**
2. Click **"Actions"** tab (top menu)

### 3.2 Watch Pipelines Run
You'll see 2 workflows running:
- **Frontend Continuous Deployment**
- **Backend Continuous Deployment**

### 3.3 Check Each Step
Click on a workflow to see details:

**Frontend CD should:**
1. ✅ Lint job (passes)
2. ✅ Test job (passes)
3. ✅ Build job:
   - Builds Docker image
   - Logs into ECR
   - Pushes image to ECR
   - Tags with git SHA
4. ✅ Deploy job:
   - Updates kustomize
   - Applies Kubernetes manifests
   - Verifies deployment

**Backend CD should:**
1. ✅ Lint job (passes)
2. ✅ Test job (passes)
3. ✅ Build job:
   - Builds Docker image
   - Logs into ECR
   - Pushes image to ECR
4. ✅ Deploy job:
   - Updates kustomize
   - Applies Kubernetes manifests
   - Verifies deployment

### 3.4 Wait for Completion
- ⏳ Total time: 10-15 minutes
- ✅ Green checkmark = Success
- ❌ Red X = Check logs for errors

---

## Step 4: Verify Deployment in Kubernetes

### 4.1 Configure kubectl

```bash
cd /Users/faialradhi/Shaykha-project4

# Configure kubectl to connect to your cluster
aws eks update-kubeconfig --name movie-picture-cluster --region eu-north-1
```

### 4.2 Check Deployments

```bash
# Check if deployments exist
kubectl get deployments

# Should show:
# NAME                  READY   UP-TO-DATE   AVAILABLE
# backend-deployment    2/2     2            2
# frontend-deployment   2/2     2            2
```

### 4.3 Check Services

```bash
# Check services
kubectl get services

# Should show:
# NAME              TYPE           EXTERNAL-IP      PORT(S)
# backend-service   ClusterIP      <none>           5000/TCP
# frontend-service  LoadBalancer   <external-ip>   80:xxxxx/TCP
```

### 4.4 Check Pods

```bash
# Check pods are running
kubectl get pods

# Should show pods with STATUS "Running"
```

---

## Step 5: Access Your Backend

### Method 1: Port Forward (Easiest)

**Backend:**
```bash
# Port forward backend service
kubectl port-forward svc/backend-service 5000:5000

# Keep this terminal open, then in another terminal or browser:
# Test: http://localhost:5000/movies
# Health: http://localhost:5000/health
```

**Frontend:**
```bash
# Port forward frontend service (in another terminal)
kubectl port-forward svc/frontend-service 8080:80

# Open browser: http://localhost:8080
```

### Method 2: Use External IP (If LoadBalancer)

```bash
# Get external IP
kubectl get svc frontend-service

# Look for EXTERNAL-IP column
# Use that IP in browser: http://<external-ip>
```

---

## Step 6: Test Your Application

### Test Backend API:

```bash
# With port-forward running, test:
curl http://localhost:5000/movies

# Expected response:
# {"movies":[{"id":"123","title":"Top Gun: Maverick"},...]}

# Test health:
curl http://localhost:5000/health
```

### Test Frontend:

1. Open browser: **http://localhost:8080**
2. You should see the Movie Picture Catalog
3. Movies should load from the backend

---

## Troubleshooting

### Pipeline Fails at "Login to ECR"
- ✅ Check AWS credentials in GitHub Secrets
- ✅ Verify ECR repositories exist
- ✅ Check region is `eu-north-1`

### Pipeline Fails at "Deploy to Kubernetes"
- ✅ Check EKS cluster is "Active"
- ✅ Verify cluster name in secret matches exactly
- ✅ Check node group is "Active"

### No Deployments Found
- ✅ CD pipeline didn't run or failed
- ✅ Check GitHub Actions for errors
- ✅ Make sure you merged to `main` branch

### Port Forward Fails
- ✅ Check pods are running: `kubectl get pods`
- ✅ Check service exists: `kubectl get svc`
- ✅ Wait a few minutes after deployment

### Cannot Connect to Backend
- ✅ Make sure port-forward is running
- ✅ Use `localhost`, not `backend-service`
- ✅ Check pod logs: `kubectl logs <pod-name>`

---

## Complete Checklist

- [ ] EKS cluster is "Active" in AWS Console
- [ ] Node group is "Active"
- [ ] PR merged to `main` OR pushed to `main`
- [ ] CD pipelines completed successfully in GitHub Actions
- [ ] Docker images pushed to ECR (check AWS Console → ECR)
- [ ] Deployments exist: `kubectl get deployments`
- [ ] Services exist: `kubectl get services`
- [ ] Pods are running: `kubectl get pods`
- [ ] Backend accessible via port-forward: `curl http://localhost:5000/movies`
- [ ] Frontend accessible via port-forward: `http://localhost:8080`

---

## Quick Commands Summary

```bash
# 1. Configure kubectl
aws eks update-kubeconfig --name movie-picture-cluster --region eu-north-1

# 2. Check everything
kubectl get deployments
kubectl get services
kubectl get pods

# 3. Access backend
kubectl port-forward svc/backend-service 5000:5000
# Then: curl http://localhost:5000/movies

# 4. Access frontend
kubectl port-forward svc/frontend-service 8080:80
# Then: open http://localhost:8080
```

---

## 🎉 Success!

Once all steps complete:
- ✅ Your CI/CD pipeline is working
- ✅ Applications are deployed to Kubernetes
- ✅ Backend and frontend are accessible
- ✅ Ready to submit your project!

