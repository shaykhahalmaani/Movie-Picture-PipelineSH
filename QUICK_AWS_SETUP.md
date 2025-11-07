# Quick AWS Setup - Step by Step

## 🎯 What You Need (In Order)

1. **AWS Account** ✅ (You have this)
2. **IAM User** with access keys
3. **ECR Repositories** (2 repositories)
4. **EKS Cluster** (1 cluster)
5. **GitHub Secrets** (add credentials)

---

## Step 1: Create IAM User (5 minutes)

### Go to IAM:
1. AWS Console → Search "IAM" → Click **IAM**

### Create User:
1. Click **Users** → **Create user**
2. Name: `github-action-user`
3. Click **Next**
4. Select **Attach policies directly**
5. Check these policies:
   - ✅ `AmazonEC2FullAccess`
   - ✅ `AmazonECRFullAccess`
   - ✅ `AmazonEKSFullAccess`
6. Click **Next** → **Create user**

### Get Access Keys:
1. Click on `github-action-user`
2. Tab: **Security credentials**
3. **Access keys** → **Create access key**
4. Select: **Application running outside AWS**
5. Click **Create access key**
6. **Copy both:**
   - Access key ID: `AKIA...`
   - Secret access key: `xxxxx...`
   - ⚠️ Save these! You'll need them for GitHub!

---

## Step 2: Create ECR Repositories (3 minutes)

### Go to ECR:
1. AWS Console → Search "ECR" → Click **Elastic Container Registry**

### Create Repositories:
1. Click **Create repository**
2. **Visibility**: Private
3. **Name**: `movies-frontend`
4. Click **Create repository** ✅

5. Click **Create repository** again
6. **Name**: `movies-backend`
7. Click **Create repository** ✅

**Done!** You now have 2 repositories.

---

## Step 3: Create EKS Cluster (15-20 minutes)

### Option A: Using AWS Console (Easier for Beginners)

1. **Go to EKS:**
   - AWS Console → Search "EKS" → Click **Elastic Kubernetes Service**

2. **Create Cluster:**
   - Click **Create cluster**
   - **Name**: `movie-picture-cluster`
   - **Kubernetes version**: Latest (1.28+)
   - **Region**: `us-east-1` (or your preferred region)

3. **Service Role:**
   - Click **Create new role**
   - Name: `eks-cluster-role`
   - Click **Create**
   - Select this role

4. **VPC:**
   - Use default VPC or create new
   - Select subnets

5. **Add Node Group:**
   - Click **Add node group**
   - **Name**: `movie-nodes`
   - **Instance type**: `t3.small` (cheaper) or `t3.medium`
   - **Node count**: 2
   - **Disk size**: 20 GB
   - Click **Create**

6. **Wait:**
   - Takes 10-15 minutes
   - Status will show "Active" when done
   - **Note the cluster name!**

### Option B: Using Terraform (If you have setup files)

See detailed instructions in `AWS_SETUP_GUIDE.md`

---

## Step 4: Get Your Cluster Name

After EKS cluster is created:

1. Go to EKS Console
2. Click on your cluster name
3. **Copy the cluster name** (e.g., `movie-picture-cluster`)
4. **Note the region** (e.g., `us-east-1`)

---

## Step 5: Add to GitHub Secrets (2 minutes)

1. Go to: **https://github.com/shaykhahalmaani/Movie-Picture-PipelineSH/settings/secrets/actions**

2. Click **New repository secret** for each:

   **Secret 1:**
   - Name: `AWS_ACCESS_KEY_ID`
   - Value: `AKIA...` (from Step 1)

   **Secret 2:**
   - Name: `AWS_SECRET_ACCESS_KEY`
   - Value: `xxxxx...` (from Step 1)

   **Secret 3:**
   - Name: `EKS_CLUSTER_NAME`
   - Value: `movie-picture-cluster` (from Step 4)

   **Secret 4:** (Optional)
   - Name: `REACT_APP_MOVIE_API_URL`
   - Value: `http://backend-service:5000`

---

## Step 6: Update Workflow Region (If Needed)

If your region is NOT `us-east-1`:

1. Edit `.github/workflows/frontend-cd.yaml`
   - Find: `AWS_REGION: us-east-1`
   - Change to your region

2. Edit `.github/workflows/backend-cd.yaml`
   - Same change

---

## ✅ Checklist

- [ ] IAM user created with access keys
- [ ] ECR repositories created (`movies-frontend`, `movies-backend`)
- [ ] EKS cluster created and active
- [ ] Cluster name noted
- [ ] GitHub secrets added
- [ ] Workflow region updated (if needed)

---

## 🧪 Test Your Setup

1. **Create a test PR:**
   - Make a small change in `frontend/` or `backend/`
   - Create PR to `main`
   - Check Actions tab - CI should run

2. **Merge PR:**
   - Merge to `main`
   - Check Actions tab - CD should run
   - Watch for deployment to EKS

---

## 💰 Cost Estimate

- **EKS**: ~$72/month
- **EC2 Nodes**: ~$30-60/month (2 t3.small)
- **Total**: ~$100-150/month

⚠️ **Destroy when done!**

---

## 🆘 Need Help?

- **IAM Issues**: Check user has correct policies
- **ECR Issues**: Verify repositories exist
- **EKS Issues**: Check cluster is "Active"
- **GitHub Actions**: Check secrets are correct

---

## 🎉 You're Done!

Once all secrets are added, your pipelines will:
1. ✅ Run CI on PRs
2. ✅ Build Docker images
3. ✅ Push to ECR
4. ✅ Deploy to EKS
5. ✅ Your app will be live!

