#!/bin/sh -xe
if ! command -v kubectl &> /dev/null; then
curl -LO "https://dl.k8s.io/release/v1.31.0/bin/linux/amd64/kubectl"
chmod +x kubectl
export PATH=$PATH:$PWD
fi
kubectl get deployment nginx-imperative > /dev/null 2>&1
if [ $? -eq 0 ]; then
kubectl delete deployment nginx-imperative
echo "Deleted existing nginx-imperative deployment"
# Wait for deletion to complete
sleep 5
fi
# Create new deployment with 2 replicas
kubectl create deployment nginx-imperative --image=nginx --replicas=2
echo "Created new nginx-imperative deployment with 2 replicas"
# Monitor deployment readiness
echo "Checking deployment status..."
kubectl wait --for=condition=available --timeout=60s deployment/nginx-imperative
echo "Deployment nginx-imperative is ready with 2 replicas"
