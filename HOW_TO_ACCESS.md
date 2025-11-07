# How to Access Your Backend/Frontend

## ⚠️ Important: Service Names are Internal

`http://backend-service:5000` is a **Kubernetes internal service name** - it only works **inside the cluster**, not from your browser!

---

## Step 1: Check if Deployments Exist

First, verify your applications are deployed:

```bash
# Configure kubectl
aws eks update-kubeconfig --name movie-picture-cluster --region eu-north-1

# Check deployments
kubectl get deployments

# Check services
kubectl get services

# Check pods
kubectl get pods
```

**If you see "No resources found"**, nothing is deployed yet!

---

## Step 2: Deploy Applications First

You need to **trigger the CD pipeline** to deploy:

1. **Merge a PR to `main` branch** (or push directly to main)
2. Go to **Actions** tab in GitHub
3. Watch **Frontend CD** and **Backend CD** pipelines run
4. Wait for them to complete

---

## Step 3: Access Your Services

### Option A: Port Forward (Easiest for Testing)

**Backend:**
```bash
kubectl port-forward svc/backend-service 5000:5000
```
Then open: http://localhost:5000/movies

**Frontend:**
```bash
kubectl port-forward svc/frontend-service 8080:80
```
Then open: http://localhost:8080

### Option B: Get External IP (LoadBalancer)

**Check if service has external IP:**
```bash
kubectl get svc frontend-service
```

If you see an `EXTERNAL-IP` (not `<pending>`), use that URL.

If it shows `<pending>`, wait a few minutes or check:
- LoadBalancer might take time to provision
- Check AWS Console → EC2 → Load Balancers

---

## Step 4: Verify Everything is Working

### Test Backend:
```bash
# Port forward
kubectl port-forward svc/backend-service 5000:5000

# In another terminal, test:
curl http://localhost:5000/movies
curl http://localhost:5000/health
```

Expected response:
```json
{"movies":[{"id":"123","title":"Top Gun: Maverick"},...]}
```

### Test Frontend:
```bash
# Port forward
kubectl port-forward svc/frontend-service 8080:80

# Open browser:
open http://localhost:8080
```

---

## Troubleshooting

### "No resources found"
- ✅ Deployments haven't been created yet
- **Solution**: Trigger CD pipeline by merging PR to main

### "Connection refused" or timeout
- ✅ Pods might not be running
- **Solution**: 
  ```bash
  kubectl get pods
  kubectl logs <pod-name>
  kubectl describe pod <pod-name>
  ```

### "Service not found"
- ✅ Service wasn't created
- **Solution**: Check if CD pipeline completed successfully
- Check Kubernetes manifests in `frontend/k8s/` and `backend/k8s/`

### Port forward fails
- ✅ Service doesn't exist or pods aren't ready
- **Solution**: 
  ```bash
  kubectl get svc
  kubectl get pods
  ```

---

## Quick Checklist

- [ ] EKS cluster is "Active" in AWS Console
- [ ] Node group is "Active" 
- [ ] CD pipeline has run successfully
- [ ] Deployments exist: `kubectl get deployments`
- [ ] Services exist: `kubectl get services`
- [ ] Pods are running: `kubectl get pods`
- [ ] Use port-forward to access: `kubectl port-forward svc/backend-service 5000:5000`

---

## Remember

- `backend-service` is **internal** - use `localhost` with port-forward
- Nothing is accessible until **CD pipeline deploys**
- Check **GitHub Actions** to see if deployment succeeded

