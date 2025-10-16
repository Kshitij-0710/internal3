# 🚀 Internal3 — FastAPI + CI/CD + Kubernetes (Minikube)

A tiny **FastAPI app** with a working **CI/CD pipeline** using:
- **GitHub Actions** → Build & push image  
- **GHCR (GitHub Container Registry)** → Store image  
- **Minikube** → Local Kubernetes deployment  

---

## ⚙️ Setup

### 1. Clone the repo
```bash
git clone https://github.com/<your-username>/internal3.git
cd internal3
2. Run locally
bash
Copy code
docker build -t mini-api:local .
docker run -p 8080:8080 mini-api:local
Then open 👉 http://localhost:8080

Expected output:

json
Copy code
{"message": "Hello from GitLab CI/CD 🚀"}
☸️ Deploy on Minikube
Make sure Minikube is running:

bash
Copy code
minikube start --cpus=2 --memory=4096
Pull the image from GHCR (replace <your-username> below 👇):

bash
Copy code
docker pull ghcr.io/<your-username>/internal3:latest
minikube image load ghcr.io/<your-username>/internal3:latest
kubectl apply -f k8s-deployment.yaml
minikube service mini-api
🔐 GitHub Actions Secrets
In your GitHub repo → Settings → Secrets → Actions, add:

ini
Copy code
GHCR_USERNAME = <your-github-username>
GHCR_TOKEN = <your-personal-access-token>
Your deploy.yml workflow will:

Build and push your Docker image to GHCR

(Optionally) deploy using kubectl if a remote cluster is configured

🧰 Quick Update Script
Create update.sh to reload the latest build:

bash
Copy code
docker pull ghcr.io/<your-username>/internal3:latest
minikube image load ghcr.io/<your-username>/internal3:latest
kubectl rollout restart deployment/mini-api
Then run:

bash
Copy code
./update.sh
