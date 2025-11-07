# Make Your Services Accessible - Persistent Access

## The Problem

Port-forward (`kubectl port-forward`) only works **while the command is running**. When you close the terminal or stop it, the service is no longer accessible.

## Solution: Use LoadBalancer Service

Your frontend service is already configured as `LoadBalancer`, but we need to make sure it's set up correctly.

---

## Step 1: Check Your Services

```bash
# Configure kubectl
aws eks update-kubeconfig --name movie-picture-cluster --region eu-north-1

# Check services
kubectl get services
```

**Look for:**
- `frontend-service` should have `TYPE: LoadBalancer`
- It should have an `EXTERNAL-IP` (might take a few minutes)

---

## Step 2: Get External IP Address

```bash
# Get frontend service external IP
kubectl get svc frontend-service

# Wait for EXTERNAL-IP to appear (not <pending>)
# It will look like: 34.123.45.67
```

### If External IP is `<pending>`:

1. **Wait 2-5 minutes** - LoadBalancer takes time to provision
2. **Check AWS Console:**
   - Go to EC2 → Load Balancers
   - You should see a new load balancer being created
   - Wait until it's "Active"

---

## Step 3: Access Your Services

### Frontend (Using External IP):

Once you have the EXTERNAL-IP:
```bash
# Get the IP
kubectl get svc frontend-service

# Open in browser:
http://<EXTERNAL-IP>
# Example: http://34.123.45.67
```

### Backend (Make it accessible):

The backend is currently `ClusterIP` (internal only). To make it accessible:

**Option A: Keep Port-Forward Running**
```bash
# Run this in a terminal and keep it open:
kubectl port-forward svc/backend-service 5000:5000
# Then access: http://localhost:5000/movies
```

**Option B: Change Backend to LoadBalancer**

I can update the backend service to use LoadBalancer so it gets an external IP too.

---

## Step 4: Make Port-Forward Persistent (Alternative)

If you want to keep port-forward running in the background:

```bash
# Run in background
nohup kubectl port-forward svc/backend-service 5000:5000 > /dev/null 2>&1 &

# Or run in a screen/tmux session
screen -S port-forward
kubectl port-forward svc/backend-service 5000:5000
# Press Ctrl+A then D to detach
```

---

## Quick Fix: Check Current Status

Run these commands to see what you have:

```bash
# 1. Check services
kubectl get svc

# 2. Check if frontend has external IP
kubectl get svc frontend-service -o wide

# 3. Check deployments
kubectl get deployments

# 4. Check pods
kubectl get pods
```

---

## What Do You See?

Tell me:
1. What does `kubectl get svc` show?
2. Does `frontend-service` have an EXTERNAL-IP?
3. Are you trying to access from browser or terminal?

Then I can help you fix it!

