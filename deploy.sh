#!/bin/sh -xe
if ! command -v kubectl &> /dev/null; then
    curl -LO "https://dl.k8s.io/release/v1.31.0/bin/linux/amd64/kubectl"
    chmod +x kubectl
    export PATH=$PATH:$PWD
fi
# Check if deployment exists and scale it down
if kubectl get deployment nginx-imperative &> /dev/null; then
    kubectl scale deployment nginx-imperative --replicas=0
    echo "Scaled down existing nginx-imperative deployment"
fi
# Create new deployment with 2 replicas
kubectl create deployment nginx-imperative --image=nginx --replicas=2
