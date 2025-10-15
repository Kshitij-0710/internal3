🚀 Internal3 — FastAPI + CI/CD + Kubernetes (Minikube)

A minimal FastAPI microservice that demonstrates a complete CI/CD pipeline:

✅ Build & Push Docker image via GitHub Actions

✅ Store container images in GitHub Container Registry (GHCR)

✅ Deploy automatically (locally) on Kubernetes (Minikube)

📦 Project Structure
internal3/
├── app/
│   └── main.py            # FastAPI app
├── Dockerfile             # Docker image definition
├── k8s-deployment.yaml    # Kubernetes deployment + service
├── requirements.txt       # Python dependencies
└── .github/
    └── workflows/
        └── deploy.yml     # CI/CD workflow for GitHub Actions

⚙️ Prerequisites

Before you start, ensure you have the following installed locally:

Tool	Minimum Version	Purpose
Docker
	20+	Build & run containers
Minikube
	1.30+	Local Kubernetes cluster
Kubectl
	1.25+	Interact with Kubernetes
Python
	3.11	Run the FastAPI app locally
🧠 FastAPI App (local test)

To verify the app runs before deploying:

docker build -t mini-api:local .
docker run -p 8080:8080 mini-api:local


Then visit http://localhost:8080

You should see:

{"message": "Hello from GitLab CI/CD 🚀"}

🐳 GitHub Container Registry (GHCR) Setup

Create a Personal Access Token (PAT) with the following scopes:

✅ read:packages

✅ write:packages

✅ delete:packages

In your GitHub repository → Settings → Secrets → Actions, add:

GHCR_USERNAME = kshitij-0710
GHCR_TOKEN = <your_pat_token>

⚙️ GitHub Actions CI/CD Workflow

Your workflow file:
📍 .github/workflows/deploy.yml

It performs:

Build → Docker image from your Dockerfile

Push → Upload image to GHCR as ghcr.io/kshitij-0710/internal3:latest

(Optional) Deploy → to a reachable cluster (if configured with KUBECONFIG)

☸️ Local Kubernetes Deployment (Minikube)
Start Minikube
minikube start --cpus=2 --memory=4096 --driver=docker

Load and Deploy Locally

Since GitHub Actions can’t access your local cluster, deploy manually:

# 1. Login to GHCR (only first time)
echo "<YOUR_PAT>" | docker login ghcr.io -u kshitij-0710 --password-stdin

# 2. Pull the latest image pushed by GitHub Actions
docker pull ghcr.io/kshitij-0710/internal3:latest

# 3. Load image into Minikube
minikube image load ghcr.io/kshitij-0710/internal3:latest

# 4. Apply Kubernetes manifest
kubectl apply -f k8s-deployment.yaml
kubectl rollout status deployment/mini-api

View the Pod and Service
kubectl get pods -o wide
kubectl get svc mini-api -o wide


You should see:

NAME                        READY   STATUS    RESTARTS   AGE
mini-api-xxxxxxxxxx-xxxxx   1/1     Running   0          1m

Access the Service
minikube service mini-api --url


Then open the URL shown — e.g.:

http://192.168.49.2:30328


Expected response:

{"message": "Hello from GitLab CI/CD 🚀"}

🧰 Optional: Auto-Reload Script (update.sh)

You can create a small script to automatically pull, load, and redeploy the newest image:

#!/bin/bash
set -e
echo "🔁 Updating mini-api from GHCR..."
docker pull ghcr.io/kshitij-0710/internal3:latest
minikube image load ghcr.io/kshitij-0710/internal3:latest
kubectl rollout restart deployment/mini-api
kubectl rollout status deployment/mini-api
echo "✅ Updated and running!"


Make it executable:

chmod +x update.sh


Now each time your GitHub Action completes:

./update.sh


and you’ll have the newest version running instantly 🚀

🧩 Troubleshooting
Issue	Cause	Fix
❌ connection refused :8080	GitHub Actions can’t reach local Minikube	Deploy manually using Option A (pull + load)
❌ ImagePullBackOff	Minikube can’t access GHCR (private)	Either load manually or create imagePullSecret
❌ permission_denied: expected scopes	Missing write:packages on PAT	Regenerate PAT with proper scopes
❌ Service <pending>	Minikube LoadBalancer doesn’t expose externally	Use minikube service mini-api instead
💡 Next Steps

🛜 Move deployment to a remote cluster (GKE / AKS / K3s) to make Actions fully automatic

🧱 Add multiple environments: dev, staging, prod

🧩 Extend FastAPI app with more endpoints

🔐 Secure your GHCR with least-privilege PATs

👨‍💻 Author

Kshitij Moghe
GitHub: @kshitij-0710