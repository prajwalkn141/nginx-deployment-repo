#!/bin/sh -xe
if ! command -v kubectl &> /dev/null; then
    echo "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/v1.31.0/bin/linux/amd64/kubectl"
    chmod +x kubectl
    export PATH=$PWD:$PATH
fi
kubectl version --client || { echo "kubectl failed to run"; exit 1; }
if ! command -v trivy &> /dev/null; then
    echo "Installing Trivy..."
    curl -LO https://github.com/aquasecurity/trivy/releases/download/v0.64.1/trivy_0.64.1_Linux-64bit.tar.gz
    tar -xzf trivy_0.64.1_Linux-64bit.tar.gz trivy
    chmod +x trivy
    export PATH=$PWD:$PATH
    rm trivy_0.64.1_Linux-64bit.tar.gz
fi
trivy image --exit-code 1 --severity CRITICAL --format table --output scan_nginx.txt nginx:latest
if [ $? -eq 0 ]; then
    echo "No critical vulnerabilities found, proceeding with deployment."
    kubectl get deployment nginx-imperative > /dev/null 2>&1 || true
    if [ $? -eq 0 ]; then
        kubectl delete deployment nginx-imperative --ignore-not-found
        echo "Deleted existing nginx-imperative deployment"
        sleep 5
    fi
    echo "Attempting to create deployment..."
    kubectl create deployment nginx-imperative --image=nginx --replicas=2 || { echo "Create failed: $?"; exit 1; }
    echo "Created new nginx-imperative deployment with 2 replicas"
    echo "Checking deployment status..."
    kubectl wait --for=condition=available --timeout=60s deployment/nginx-imperative || { echo "Wait failed: $?"; exit 1; }
    echo "Deployment nginx-imperative is ready with 2 replicas"
else
    echo "Critical vulnerabilities found, aborting deployment."
    exit 1
fi
