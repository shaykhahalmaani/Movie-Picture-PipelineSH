# Step-by-Step AWS Setup Guide

## 🎯 What We're Doing
1. Create ECR repositories (2 repositories)
2. Create EKS cluster (1 cluster)
3. Add credentials to GitHub

---

## Step 1: Create ECR Repositories (5 minutes)

### 1.1 Go to ECR Console
1. Open: **https://console.aws.amazon.com**
2. Sign in with your account
3. In the search bar at the top, type: **ECR**
4. Click on **"Elastic Container Registry"**

### 1.2 Create Frontend Repository
1. Click the **"Create repository"** button (blue button, top right)
2. **Repository name**: Type `movies-frontend`
3. **Visibility settings**: Keep **"Private"** selected
4. Leave everything else as default
5. Scroll down and click **"Create repository"** button
6. ✅ You'll see "Repository created successfully"

### 1.3 Create Backend Repository
1. Click **"Create repository"** again (same button)
2. **Repository name**: Type `movies-backend`
3. **Visibility settings**: Keep **"Private"** selected
4. Leave everything else as default
5. Scroll down and click **"Create repository"** button
6. ✅ You'll see "Repository created successfully"

**✅ Done!** You now have 2 repositories.

---

## Step 2: Create EKS Cluster (15-20 minutes)

### 2.1 Go to EKS Console
1. In AWS Console, search bar at top, type: **EKS**
2. Click on **"Elastic Kubernetes Service"**

### 2.2 Create Cluster
1. Click the **"Create cluster"** button (orange button, top right)
2. You'll see a form with several sections

### 2.3 Configure Cluster
**In the "Configure cluster" section:**
- **Name**: Type `movie-picture-cluster`
- **Kubernetes version**: Select the latest (usually 1.28 or 1.29)
- **Cluster service role**: Click **"Create new role"**
  - A new window opens
  - Click **"Create"** (it auto-fills the name)
  - Click **"Create role"** button
  - Go back to EKS tab (don't close it)

**In the "Networking" section:**
- **VPC**: Select the default VPC (usually named "default" or has a VPC ID)
- **Subnets**: Select all available subnets (check all boxes)
- **Security groups**: Leave default
- **Endpoint access**: Select **"Public and private"** or **"Public"**

**In the "Add-ons" section:**
- Leave defaults (VPC CNI, CoreDNS, kube-proxy are checked)

### 2.4 Create Cluster
1. Scroll to bottom
2. Click **"Create"** button
3. ⏳ **Wait 10-15 minutes** - Status will show "Creating..."
4. When status changes to **"Active"**, you're done!

**✅ Done!** Cluster is creating.

---

## Step 3: Add Node Group (While Cluster is Creating)

### 3.1 Go to Your Cluster
1. Click on your cluster name: `movie-picture-cluster`
2. Wait until you see **"Compute"** tab

### 3.2 Add Node Group
1. Click **"Compute"** tab
2. Click **"Add node group"** button
3. **Node group name**: Type `movie-nodes`
4. **Node IAM role**: Click **"Create new role"**
   - Click **"Create"** button
   - Click **"Create role"** button
   - Go back to EKS tab

### 3.3 Configure Node Group
**In "Compute configuration":**
- **Instance types**: Select `t3.small` (or `t3.medium` if you want faster)
- **Disk size**: Type `20`
- **Node group scaling configuration**:
  - **Minimum size**: `2`
  - **Maximum size**: `3`
  - **Desired size**: `2`

**In "Networking":**
- **Subnets**: Select all subnets (check all boxes)

**In "Update configuration":**
- Leave defaults

### 3.4 Create Node Group
1. Scroll to bottom
2. Click **"Create"** button
3. ⏳ **Wait 5-10 minutes** - Status will show "Creating..."
4. When status changes to **"Active"**, you're done!

**✅ Done!** Node group is creating.

---

## Step 4: Add Credentials to GitHub (2 minutes)

### 4.1 Go to GitHub Secrets
1. Open: **https://github.com/shaykhahalmaani/Movie-Picture-PipelineSH**
2. Click **"Settings"** tab (top menu)
3. In left sidebar, click **"Secrets and variables"**
4. Click **"Actions"**

### 4.2 Add Secret 1: AWS_ACCESS_KEY_ID
1. Click **"New repository secret"** button
2. **Name**: Type `AWS_ACCESS_KEY_ID`
3. **Secret**: Type `AKIA2ONKSSWGXQMGALVP`
4. Click **"Add secret"**

### 4.3 Add Secret 2: AWS_SECRET_ACCESS_KEY
1. Click **"New repository secret"** button
2. **Name**: Type `AWS_SECRET_ACCESS_KEY`
3. **Secret**: Type `IozaDUvSUfrn1TaSEYjgpeM6NOY4EzV/tHIDjbeJ`
4. Click **"Add secret"**

### 4.4 Add Secret 3: EKS_CLUSTER_NAME
1. Click **"New repository secret"** button
2. **Name**: Type `EKS_CLUSTER_NAME`
3. **Secret**: Type `movie-picture-cluster`
4. Click **"Add secret"**

### 4.5 Add Secret 4: REACT_APP_MOVIE_API_URL (Optional)
1. Click **"New repository secret"** button
2. **Name**: Type `REACT_APP_MOVIE_API_URL`
3. **Secret**: Type `http://backend-service:5000`
4. Click **"Add secret"**

**✅ Done!** All secrets added.

---

## Step 5: Verify Everything

### 5.1 Check ECR Repositories
1. Go to ECR Console
2. You should see:
   - ✅ `movies-frontend`
   - ✅ `movies-backend`

### 5.2 Check EKS Cluster
1. Go to EKS Console
2. You should see:
   - ✅ `movie-picture-cluster` with status **"Active"**
3. Click on cluster name
4. Click **"Compute"** tab
5. You should see:
   - ✅ `movie-nodes` with status **"Active"**

### 5.3 Check GitHub Secrets
1. Go to: **https://github.com/shaykhahalmaani/Movie-Picture-PipelineSH/settings/secrets/actions**
2. You should see 4 secrets:
   - ✅ `AWS_ACCESS_KEY_ID`
   - ✅ `AWS_SECRET_ACCESS_KEY`
   - ✅ `EKS_CLUSTER_NAME`
   - ✅ `REACT_APP_MOVIE_API_URL`

---

## Step 6: Test Your Setup

### 6.1 Test CI Pipeline
1. Go to your repository: **https://github.com/shaykhahalmaani/Movie-Picture-PipelineSH**
2. Click **"Actions"** tab
3. Create a test branch:
   ```bash
   git checkout -b test-ci
   echo "# Test" >> frontend/README.md
   git add frontend/README.md
   git commit -m "Test CI"
   git push origin test-ci
   ```
4. Create a Pull Request to `main`
5. Go to Actions tab - you should see Frontend CI running!

### 6.2 Test CD Pipeline
1. Merge the PR to `main`
2. Go to Actions tab
3. You should see Frontend CD pipeline:
   - Builds Docker image
   - Pushes to ECR
   - Deploys to EKS

---

## ✅ Checklist

- [ ] ECR repository `movies-frontend` created
- [ ] ECR repository `movies-backend` created
- [ ] EKS cluster `movie-picture-cluster` created and Active
- [ ] Node group `movie-nodes` created and Active
- [ ] GitHub secret `AWS_ACCESS_KEY_ID` added
- [ ] GitHub secret `AWS_SECRET_ACCESS_KEY` added
- [ ] GitHub secret `EKS_CLUSTER_NAME` added
- [ ] GitHub secret `REACT_APP_MOVIE_API_URL` added

---

## 🆘 Troubleshooting

### EKS Cluster Creation Fails
- Check your AWS account limits
- Verify you have permissions
- Try a different region

### GitHub Actions Fail
- Verify secrets are spelled correctly
- Check ECR repositories exist
- Verify EKS cluster name matches exactly

### Node Group Creation Fails
- Wait for cluster to be fully Active first
- Check instance type availability in your region
- Verify subnets are selected

---

## 💰 Cost Reminder

- EKS Cluster: ~$72/month
- EC2 Nodes (2x t3.small): ~$30/month
- **Total: ~$100-150/month**

⚠️ **Remember to delete resources when done!**

---

## 🎉 You're Done!

Once all steps are complete:
1. ✅ Your CI pipelines will run on PRs
2. ✅ Your CD pipelines will deploy to EKS
3. ✅ Your app will be live on Kubernetes!

Go test it by creating a PR! 🚀

