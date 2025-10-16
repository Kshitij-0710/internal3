#!/bin/bash
set -e

IMAGE="ghcr.io/kshitij-0710/internal3:latest"
DEPLOYMENT="mini-api"
SECRET_NAME="ghcr-secret"
NAMESPACE="default"

echo "🚀 Starting update for deployment '$DEPLOYMENT'"
echo "📦 Target image: $IMAGE"

# 1️⃣  Ensure secret exists
if ! kubectl get secret $SECRET_NAME -n $NAMESPACE &>/dev/null; then
  echo "🔑 Creating GHCR secret..."
  if [ -z "$GHCR_TOKEN" ]; then
    echo "❌ GHCR_TOKEN environment variable not set!"
    echo "Run: export GHCR_TOKEN=your_token_here"
    exit 1
  fi
  kubectl create secret docker-registry $SECRET_NAME \
    --docker-server=ghcr.io \
    --docker-username=kshitij-0710 \
    --docker-password=$GHCR_TOKEN \
    --namespace=$NAMESPACE
  kubectl patch serviceaccount default -p "{\"imagePullSecrets\": [{\"name\": \"$SECRET_NAME\"}]}" -n $NAMESPACE
else
  echo "✅ GHCR secret '$SECRET_NAME' already exists."
fi

# 2️⃣  Pull new image and load to Minikube cache (optional but fast)
echo "⬇️ Pulling latest image from GHCR..."
docker login ghcr.io -u kshitij-0710 -p $GHCR_TOKEN >/dev/null 2>&1 || true
docker pull $IMAGE >/dev/null 2>&1 || echo "⚠️ Unable to pull locally (ignored)"
minikube image load $IMAGE --overwrite=true

# 3️⃣  Delete running pod(s) to force re-pull
echo "🧹 Deleting old pods to force fresh image pull..."
kubectl delete pod -l app=mini-api -n $NAMESPACE --ignore-not-found

# 4️⃣  Wait for redeploy
echo "⏳ Waiting for rollout..."
kubectl rollout status deployment/$DEPLOYMENT -n $NAMESPACE --timeout=180s

# 5️⃣  Show pods and URL
kubectl get pods -n $NAMESPACE -l app=mini-api -o wide
NODE_PORT=$(kubectl get svc mini-api -n $NAMESPACE -o jsonpath='{.spec.ports[0].nodePort}')
MINIKUBE_IP=$(minikube ip)
URL="http://$MINIKUBE_IP:$NODE_PORT"

echo "🌐 Service URL: $URL"
echo "🧪 Health check:"
curl -s $URL || echo "⚠️ Failed to connect."
echo "🎉 Update complete!"
