# How to Push to GitHub Repository

## Step 1: Create a New Repository on GitHub

1. Go to https://github.com and sign in
2. Click the **"+"** icon in the top right → **"New repository"**
3. Fill in:
   - **Repository name**: `Movie-Picture-Pipeline` (or any name you prefer)
   - **Description**: "CI/CD Pipeline for Movie Picture Catalog"
   - **Visibility**: Choose Public or Private
   - **DO NOT** check "Add a README file" (we already have one)
   - **DO NOT** add .gitignore or license (we already have them)
4. Click **"Create repository"**

## Step 2: Copy Your Repository URL

After creating the repository, GitHub will show you a page with setup instructions. You'll see a URL like:

```
https://github.com/YOUR_USERNAME/Movie-Picture-Pipeline.git
```

**Copy this URL** - you'll need it in the next step.

## Step 3: Connect Your Local Repository to GitHub

Run these commands in your terminal (replace `YOUR_USERNAME` and repository name):

```bash
cd /Users/faialradhi/Shaykha-project4

# Add all files to git
git add .

# Create initial commit
git commit -m "Initial commit: CI/CD pipeline setup"

# Add GitHub repository as remote (REPLACE THE URL BELOW)
git remote add origin https://github.com/YOUR_USERNAME/Movie-Picture-Pipeline.git

# Rename branch to main (if needed)
git branch -M main

# Push to GitHub
git push -u origin main
```

## Important: Replace These Values

In the command above, replace:
- `YOUR_USERNAME` → Your actual GitHub username
- `Movie-Picture-Pipeline` → Your repository name (if different)

### Example:
If your GitHub username is `johnsmith` and your repo is `movie-pipeline`, the command would be:
```bash
git remote add origin https://github.com/johnsmith/movie-pipeline.git
```

## Step 4: Authentication

When you run `git push`, GitHub will ask for authentication:
- **Option 1**: Use Personal Access Token (recommended)
  - Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
  - Generate new token with `repo` permissions
  - Use token as password when prompted

- **Option 2**: Use SSH (if you have SSH keys set up)
  - Change the URL to: `git@github.com:YOUR_USERNAME/Movie-Picture-Pipeline.git`

## Quick Reference

**Repository URL format:**
```
https://github.com/USERNAME/REPOSITORY-NAME.git
```

**Your repository will be at:**
```
https://github.com/YOUR_USERNAME/Movie-Picture-Pipeline
```

## After Pushing

Once pushed, you can:
1. View your code at: `https://github.com/YOUR_USERNAME/Movie-Picture-Pipeline`
2. Go to **Actions** tab to see your workflows
3. Configure **Secrets** in Settings → Secrets and variables → Actions

## Need Help?

If you're not sure what your GitHub username is:
1. Go to https://github.com
2. Click your profile picture (top right)
3. Your username is shown in the dropdown

If you need to change the remote URL later:
```bash
git remote set-url origin https://github.com/YOUR_USERNAME/NEW-REPO-NAME.git
```

