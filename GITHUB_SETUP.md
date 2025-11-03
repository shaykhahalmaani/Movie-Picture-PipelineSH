# GitHub Setup Guide

Follow these steps to set up your GitHub repository and push your code.

## Step 1: Create GitHub Repository

1. Go to [GitHub.com](https://github.com) and sign in
2. Click the "+" icon in the top right corner
3. Select "New repository"
4. Repository name: `Movie-Picture-Pipeline` (or your preferred name)
5. Description: "CI/CD Pipeline for Movie Picture Catalog"
6. Visibility: Choose Public or Private
7. **DO NOT** initialize with README, .gitignore, or license (we already have these)
8. Click "Create repository"

## Step 2: Add Remote and Push Code

After creating the repository, GitHub will show you commands. Run these in your terminal:

```bash
cd /Users/faialradhi/Shaykha-project4

# Add all files
git add .

# Commit the files
git commit -m "Initial commit: CI/CD pipeline setup with GitHub Actions"

# Add your GitHub repository as remote (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/Movie-Picture-Pipeline.git

# Push to GitHub
git branch -M main
git push -u origin main
```

**Note:** Replace `YOUR_USERNAME` with your actual GitHub username and `Movie-Picture-Pipeline` with your repository name.

## Step 3: Configure GitHub Secrets

1. Go to your repository on GitHub
2. Click on **Settings** (top menu)
3. Click on **Secrets and variables** → **Actions** (left sidebar)
4. Click **New repository secret** and add each of the following:

### Required Secrets:

1. **AWS_ACCESS_KEY_ID**
   - Name: `AWS_ACCESS_KEY_ID`
   - Value: Your AWS access key ID (from github-action-user IAM user)

2. **AWS_SECRET_ACCESS_KEY**
   - Name: `AWS_SECRET_ACCESS_KEY`
   - Value: Your AWS secret access key (from github-action-user IAM user)

3. **EKS_CLUSTER_NAME**
   - Name: `EKS_CLUSTER_NAME`
   - Value: Your EKS cluster name (from Terraform output or AWS Console)

4. **REACT_APP_MOVIE_API_URL** (Optional)
   - Name: `REACT_APP_MOVIE_API_URL`
   - Value: `http://backend-service:5000` (default, can be customized)

## Step 4: Verify Workflows

After pushing code, verify the workflows exist:

1. Go to your repository on GitHub
2. Click on **Actions** tab
3. You should see 4 workflows:
   - Frontend Continuous Integration
   - Backend Continuous Integration
   - Frontend Continuous Deployment
   - Backend Continuous Deployment

## Step 5: Test the CI Pipelines

### Test Frontend CI:
1. Create a new branch: `git checkout -b test-frontend`
2. Make a small change in `frontend/src/App.js`
3. Commit and push: 
   ```bash
   git add frontend/src/App.js
   git commit -m "Test frontend CI"
   git push origin test-frontend
   ```
4. Create a Pull Request to `main` branch
5. Go to Actions tab and watch the Frontend CI pipeline run

### Test Backend CI:
1. Create a new branch: `git checkout -b test-backend`
2. Make a small change in `backend/app.py`
3. Commit and push:
   ```bash
   git add backend/app.py
   git commit -m "Test backend CI"
   git push origin test-backend
   ```
4. Create a Pull Request to `main` branch
5. Go to Actions tab and watch the Backend CI pipeline run

## Step 6: Test CD Pipelines (After CI is Working)

Once CI pipelines are working, test the CD pipelines:

1. Merge a PR to the `main` branch (or push directly to main)
2. Go to Actions tab
3. Watch the CD pipelines:
   - They will build Docker images
   - Push to ECR
   - Deploy to Kubernetes

## Troubleshooting

### Authentication Issues
If you get authentication errors:
- Verify AWS credentials in GitHub Secrets
- Check that the IAM user has proper permissions
- Ensure ECR repositories exist

### Workflow Not Triggering
- Check that files are in the correct paths (`frontend/**` or `backend/**`)
- Verify the workflow files are in `.github/workflows/`
- Check branch name matches (should be `main`)

### Pipeline Failures
- Check the Actions tab for detailed error messages
- Verify all dependencies are in `package.json` and `Pipfile`
- Ensure Docker builds work locally first

### EKS Access Issues
- Run `setup/init.sh` to add GitHub Actions user to Kubernetes
- Verify `EKS_CLUSTER_NAME` secret is correct
- Check AWS region matches your cluster region

## Next Steps

After GitHub setup is complete:
1. ✅ Test CI pipelines with PRs
2. ✅ Set up AWS infrastructure (ECR, EKS)
3. ✅ Test CD pipelines with merges to main
4. ✅ Verify deployments on Kubernetes cluster
5. ✅ Submit screenshots/URLs showing working application

## Useful Git Commands

```bash
# Check status
git status

# Add specific files
git add <file>

# Commit changes
git commit -m "Your commit message"

# Push to GitHub
git push origin main

# Create and switch to new branch
git checkout -b <branch-name>

# View commit history
git log --oneline

# Pull latest changes
git pull origin main
```

