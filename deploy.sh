#!/bin/sh -xe
if ! command -v kubectl &> /dev/null; then
    echo "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/v1.31.0/bin/linux/amd64/kubectl"
    chmod +x kubectl
    export PATH=$PWD:$PATH  # Prepend $PWD for priority
fi
# Check kubectl version to verify
kubectl version --client || { echo "kubectl failed to run"; exit 1; }
# Check if deployment exists and delete it (ignore if not found)
kubectl get deployment nginx-imperative > /dev/null 2>&1 || true
if [ $? -eq 0 ]; then
    kubectl delete deployment nginx-imperative --ignore-not-found
    echo "Deleted existing nginx-imperative deployment"
    sleep 5
fi
# Create new deployment with 2 replicas
echo "Attempting to create deployment..."
kubectl create deployment nginx-imperative --image=nginx --replicas=2 || { echo "Create failed: $?"; exit 1; }
echo "Created new nginx-imperative deployment with 2 replicas"
# Monitor deployment readiness
echo "Checking deployment status..."
kubectl wait --for=condition=available --timeout=60s deployment/nginx-imperative || { echo "Wait failed: $?"; exit 1; }
echo "Deployment nginx-imperative is ready with 2 replicas"
