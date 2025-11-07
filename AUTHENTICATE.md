# Fix Authentication - Quick Guide

## The Problem
Git is trying to use account `77Fayy` but you need `shaykhahalmaani`.

## Solution: Use Personal Access Token

### Step 1: Create Token
1. Go to: **https://github.com/settings/tokens**
2. Click **"Generate new token"** → **"Generate new token (classic)"**
3. Name: `Movie-Picture-Pipeline`
4. Check: ✅ **`repo`** (full control of private repositories)
5. Click **"Generate token"**
6. **COPY THE TOKEN** (starts with `ghp_`)

### Step 2: Push with Token

Run this command, then use the token when prompted:

```bash
cd /Users/faialradhi/Shaykha-project4
git push -u origin main
```

**When prompted:**
- **Username**: `shaykhahalmaani`
- **Password**: Paste your token (the `ghp_...` one)

### Alternative: Use Token in URL

If you want to avoid entering credentials each time, you can embed the token in the URL:

```bash
# Replace YOUR_TOKEN with your actual token
git remote set-url origin https://YOUR_TOKEN@github.com/shaykhahalmaani/Movie-Picture-PipelineSH.git
git push -u origin main
```

**Example:**
```bash
git remote set-url origin https://ghp_abc123xyz456@github.com/shaykhahalmaani/Movie-Picture-PipelineSH.git
git push -u origin main
```

⚠️ **Note**: This stores the token in your git config. For security, consider using SSH keys instead.

---

## Quick Test
After pushing, verify at:
https://github.com/shaykhahalmaani/Movie-Picture-PipelineSH

