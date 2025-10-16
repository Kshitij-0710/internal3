#!/bin/bash

IMAGE="ghcr.io/kshitij-0710/internal3:latest"
DEPLOYMENT="mini-api"

echo "🚀 Updating Kubernetes deployment using latest image from GHCR..."
echo "📦 Image: $IMAGE"

echo "⬇️ Pulling latest image..."
docker pull $IMAGE

echo "📦 Loading image into Minikube..."
minikube image load $IMAGE

echo "🔄 Restarting deployment..."
kubectl rollout restart deployment/$DEPLOYMENT

echo "⏳ Waiting for rollout to complete..."
kubectl rollout status deployment/$DEPLOYMENT

echo "✅ Current pods:"
kubectl get pods -o wide
