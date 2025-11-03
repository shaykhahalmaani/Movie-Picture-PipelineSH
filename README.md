# Movie Picture Pipeline - CI/CD Project

This project implements CI/CD pipelines using GitHub Actions for a Movie Picture catalog web application. The application consists of a React frontend (TypeScript) and a Flask backend (Python), both deployed to Amazon EKS.

## Project Structure

```
.
├── backend/              # Python Flask API server
│   ├── app.py          # Main Flask application
│   ├── test_app.py     # Test suite
│   ├── Pipfile         # Python dependencies
│   ├── Dockerfile      # Backend container image
│   └── k8s/           # Kubernetes manifests with kustomize
├── frontend/           # React frontend application
│   ├── src/           # React source code
│   ├── public/        # Static assets
│   ├── package.json   # Frontend dependencies
│   ├── Dockerfile     # Frontend container image
│   └── k8s/          # Kubernetes manifests with kustomize
└── .github/workflows/  # GitHub Actions workflows
    ├── frontend-ci.yaml
    ├── backend-ci.yaml
    ├── frontend-cd.yaml
    └── backend-cd.yaml
```

## CI/CD Pipelines

### Frontend CI Pipeline (`frontend-ci.yaml`)
- **Trigger**: Pull requests to `main` branch (only when `frontend/**` changes)
- **Manual**: Can be run on-demand via `workflow_dispatch`
- **Jobs**:
  - `lint`: Runs ESLint checks
  - `test`: Runs Jest test suite
  - `build`: Builds Docker image (only after lint and test pass)

### Backend CI Pipeline (`backend-ci.yaml`)
- **Trigger**: Pull requests to `main` branch (only when `backend/**` changes)
- **Manual**: Can be run on-demand via `workflow_dispatch`
- **Jobs**:
  - `lint`: Runs pylint
  - `test`: Runs pytest
  - `build`: Builds Docker image (only after lint and test pass)

### Frontend CD Pipeline (`frontend-cd.yaml`)
- **Trigger**: Push to `main` branch (only when `frontend/**` changes)
- **Manual**: Can be run on-demand via `workflow_dispatch`
- **Jobs**:
  - `lint`: Runs ESLint checks
  - `test`: Runs Jest test suite
  - `build`: Builds Docker image with `REACT_APP_MOVIE_API_URL` build arg, tags with git SHA, pushes to ECR
  - `deploy`: Deploys to EKS using kustomize

### Backend CD Pipeline (`backend-cd.yaml`)
- **Trigger**: Push to `main` branch (only when `backend/**` changes)
- **Manual**: Can be run on-demand via `workflow_dispatch`
- **Jobs**:
  - `lint`: Runs pylint
  - `test`: Runs pytest
  - `build`: Builds Docker image, tags with git SHA, pushes to ECR
  - `deploy`: Deploys to EKS using kustomize

## Setup Instructions

### Prerequisites
1. AWS Account with ECR and EKS access
2. GitHub repository
3. Terraform setup (optional, see project instructions)

### GitHub Secrets Configuration

Add the following secrets to your GitHub repository (Settings → Secrets and variables → Actions):

- `AWS_ACCESS_KEY_ID`: AWS access key for GitHub Actions user
- `AWS_SECRET_ACCESS_KEY`: AWS secret key for GitHub Actions user
- `EKS_CLUSTER_NAME`: Name of your EKS cluster
- `REACT_APP_MOVIE_API_URL`: Backend API URL for frontend (optional, defaults to `http://backend-service:5000`)

### AWS Infrastructure Setup

#### Option 1: Using Terraform (Recommended)

1. Install Terraform:
```bash
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
export PATH="$HOME/.tfenv/bin:$PATH"
tfenv install 1.3.9
tfenv use 1.3.9
```

2. Create AWS IAM user with Administrator access

3. Set AWS credentials:
```bash
export AWS_ACCESS_KEY_ID={your-access-key}
export AWS_SECRET_ACCESS_KEY={your-secret-key}
```

4. Apply Terraform:
```bash
cd setup/terraform
terraform init
terraform apply
```

5. Note the Terraform outputs for ECR repository URLs and EKS cluster name

6. Run init script to add GitHub Actions user to Kubernetes:
```bash
cd setup
./init.sh
```

#### Option 2: Manual AWS Console Setup

1. Create ECR repositories:
   - `movies-frontend`
   - `movies-backend`

2. Create EKS cluster

3. Configure kubectl:
```bash
aws eks update-kubeconfig --name <cluster-name> --region <region>
```

### Local Development

#### Backend
```bash
cd backend
pipenv install
pipenv run serve
```

#### Frontend
```bash
cd frontend
npm install
REACT_APP_MOVIE_API_URL=http://localhost:5000 npm start
```

### Testing Locally

#### Backend Tests
```bash
cd backend
pipenv run test
pipenv run lint
```

#### Frontend Tests
```bash
cd frontend
npm test
npm run lint
```

### Docker Builds

#### Backend
```bash
cd backend
docker build --tag mp-backend:latest .
docker run -p 5000:5000 mp-backend
```

#### Frontend
```bash
cd frontend
docker build --build-arg=REACT_APP_MOVIE_API_URL=http://localhost:5000 --tag mp-frontend:latest .
docker run -p 3000:3000 mp-frontend
```

### Kubernetes Deployment

#### Using kustomize (as in CI/CD)
```bash
# Backend
cd backend/k8s
kustomize edit set image backend=<ECR_REPO_URL>:<TAG>
kustomize build | kubectl apply -f -

# Frontend
cd frontend/k8s
kustomize edit set image frontend=<ECR_REPO_URL>:<TAG>
kustomize build | kubectl apply -f -
```

## Verification

After deployment:

1. Check backend:
```bash
kubectl get svc backend-service
kubectl port-forward svc/backend-service 5000:5000
curl http://localhost:5000/movies
```

2. Check frontend:
```bash
kubectl get svc frontend-service
kubectl port-forward svc/frontend-service 8080:80
# Open http://localhost:8080
```

## Cleanup

After completing the project, tear down AWS resources:

```bash
cd setup/terraform
terraform destroy
```

## Project Requirements Checklist

✅ Frontend CI pipeline (lint, test, build on PR)  
✅ Backend CI pipeline (lint, test, build on PR)  
✅ Frontend CD pipeline (deploy to ECR and EKS)  
✅ Backend CD pipeline (deploy to ECR and EKS)  
✅ Workflows triggered on PR/push events  
✅ Workflows run only when respective code changes  
✅ Manual workflow dispatch support  
✅ Docker image tagging with git SHA  
✅ ECR authentication using GitHub Actions  
✅ Kubernetes deployment using kustomize  
✅ Build args for frontend environment variables  

## Notes

- All workflows use path filters to only run when relevant code changes
- Docker images are tagged with both git SHA and `latest`
- The frontend build uses `REACT_APP_MOVIE_API_URL` build argument
- Kubernetes deployments use kustomize for dynamic image tag updates
- All AWS credentials are stored in GitHub Secrets (never hardcoded)
