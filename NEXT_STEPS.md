# Next Steps - Test Your CI/CD Pipeline

## ✅ What You've Completed
- ✅ ECR repositories created (`movies-frontend`, `movies-backend`)
- ✅ EKS cluster created (`movie-picture-cluster`)
- ✅ GitHub secrets added
- ✅ Workflows updated for `eu-north-1` region

---

## 🧪 Step 1: Test CI Pipelines (Create a PR)

### Test Frontend CI:
```bash
cd /Users/faialradhi/Shaykha-project4

# Create a test branch
git checkout -b test-frontend-ci

# Make a small change
echo "# Frontend Test" >> frontend/TEST.md
git add frontend/TEST.md
git commit -m "Test frontend CI pipeline"
git push origin test-frontend-ci
```

1. Go to: https://github.com/shaykhahalmaani/Movie-Picture-PipelineSH
2. Click **"Compare & pull request"** button
3. Create PR to `main` branch
4. Go to **Actions** tab
5. Watch **Frontend Continuous Integration** run!

It should:
- ✅ Run linting
- ✅ Run tests
- ✅ Build Docker image

### Test Backend CI:
```bash
# Create another test branch
git checkout -b test-backend-ci
echo "# Backend Test" >> backend/TEST.md
git add backend/TEST.md
git commit -m "Test backend CI pipeline"
git push origin test-backend-ci
```

1. Create PR to `main`
2. Go to **Actions** tab
3. Watch **Backend Continuous Integration** run!

---

## 🚀 Step 2: Test CD Pipelines (Merge to Main)

After CI passes:

1. **Merge the PR** to `main` branch
2. Go to **Actions** tab
3. Watch **Continuous Deployment** pipeline:
   - ✅ Builds Docker image
   - ✅ Pushes to ECR
   - ✅ Deploys to EKS

---

## 🔍 Step 3: Verify Deployment

### Check ECR Repositories:
1. Go to AWS Console → ECR
2. Click on `movies-frontend` repository
3. You should see Docker images with tags (git SHA)
4. Same for `movies-backend`

### Check EKS Deployment:
1. Go to AWS Console → EKS
2. Click on `movie-picture-cluster`
3. Go to **Workloads** tab
4. You should see:
   - `frontend-deployment`
   - `backend-deployment`

### Check with kubectl:
```bash
# Configure kubectl
aws eks update-kubeconfig --name movie-picture-cluster --region eu-north-1

# Check deployments
kubectl get deployments
kubectl get pods
kubectl get services
```

---

## 📊 Step 4: View Your Application

### Get Frontend URL:
```bash
kubectl get service frontend-service
```

Look for `EXTERNAL-IP` or use:
```bash
kubectl port-forward svc/frontend-service 8080:80
```

Then open: http://localhost:8080

### Test Backend API:
```bash
kubectl port-forward svc/backend-service 5000:5000
```

Then test:
```bash
curl http://localhost:5000/movies
```

---

## ✅ Success Checklist

- [ ] CI pipelines run on PRs
- [ ] CD pipelines run on merge to main
- [ ] Docker images pushed to ECR
- [ ] Deployments visible in EKS
- [ ] Frontend accessible
- [ ] Backend API returns movies

---

## 🎉 You're Done!

Once all steps work:
1. ✅ Your CI/CD pipeline is fully functional
2. ✅ Applications are deployed to Kubernetes
3. ✅ Ready to submit your project!

---

## 🆘 Troubleshooting

### Pipelines Fail
- Check Actions tab for error messages
- Verify secrets are correct
- Check ECR repositories exist
- Verify EKS cluster name matches

### Deployment Fails
- Check EKS cluster is "Active"
- Verify node group is "Active"
- Check kubectl configuration

### Images Not Pushing
- Verify ECR repository names match
- Check AWS credentials have ECR permissions
- Verify region is `eu-north-1`

---

## 📝 What to Submit

For project submission, you'll need:
1. ✅ GitHub repository URL
2. ✅ Screenshots of:
   - CI pipeline running successfully
   - CD pipeline running successfully
   - ECR with images
   - EKS deployments
   - Frontend application working
   - Backend API returning data

---

## 🧹 Cleanup (When Done)

To avoid charges, delete resources:

```bash
# Delete EKS cluster (in AWS Console)
# EKS → movie-picture-cluster → Delete

# Delete ECR repositories (in AWS Console)
# ECR → Select repositories → Delete

# Or use AWS CLI:
aws eks delete-cluster --name movie-picture-cluster --region eu-north-1
aws ecr delete-repository --repository-name movies-frontend --force --region eu-north-1
aws ecr delete-repository --repository-name movies-backend --force --region eu-north-1
```

---

🎯 **Start by creating a test PR to trigger the CI pipeline!**

