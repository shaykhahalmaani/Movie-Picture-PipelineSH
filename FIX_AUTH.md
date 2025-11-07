# Fix GitHub Authentication Issue

## Problem
Git is trying to use account `77Fayy` but you need to use `shaykhahalmaani` account.

## Solution Options

### Option 1: Use Personal Access Token (Recommended)

1. **Create a Personal Access Token:**
   - Go to: https://github.com/settings/tokens
   - Click "Generate new token" → "Generate new token (classic)"
   - Name: `Movie-Picture-Pipeline`
   - Select scopes: Check `repo` (all repo permissions)
   - Click "Generate token"
   - **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** (you won't see it again!)

2. **Push using the token:**
   ```bash
   cd /Users/faialradhi/Shaykha-project4
   git push -u origin main
   ```
   
   When prompted:
   - Username: `shaykhahalmaani`
   - Password: **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** (not your GitHub password)

### Option 2: Update Git Credentials

Clear cached credentials and use the correct account:

```bash
# Remove old credentials
git credential-osxkeychain erase
host=github.com
protocol=https
# Press Enter twice

# Try pushing again
cd /Users/faialradhi/Shaykha-project4
git push -u origin main
```

### Option 3: Use SSH Instead

1. **Switch to SSH URL:**
   ```bash
   cd /Users/faialradhi/Shaykha-project4
   git remote set-url origin git@github.com:shaykhahalmaani/Movie-Picture-PipelineSH.git
   git push -u origin main
   ```

### Option 4: Use Token in URL (Quick Fix)

```bash
cd /Users/faialradhi/Shaykha-project4
git remote set-url origin https://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@github.com/shaykhahalmaani/Movie-Picture-PipelineSH.git
git push -u origin main
```

Replace `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` with your personal access token.

## Recommended: Option 1 (Personal Access Token)

This is the most secure and GitHub-recommended method.

