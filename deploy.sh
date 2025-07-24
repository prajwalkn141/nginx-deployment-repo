#!/bin/sh -xe
# Ensure kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/v1.31.0/bin/linux/amd64/kubectl"
    chmod +x kubectl
    export PATH=$PWD:$PATH
fi
kubectl version --client || { echo "kubectl failed to run"; exit 1; }

# Drift Correction: Check and delete existing deployment
kubectl get deployment microservice-deployment > /dev/null 2>&1 || true
if [ $? -eq 0 ]; then
    kubectl delete deployment microservice-deployment --ignore-not-found
    echo "Deleted existing microservice-deployment"
    sleep 5
fi

# Create deployment with compliance settings
echo "Attempting to create deployment..."
kubectl create deployment microservice-deployment --image=743833337997.dkr.ecr.eu-west-1.amazonaws.com/microservice-app:latest --replicas=2 --dry-run=client -o yaml | \
sed 's/resources: {}/resources:\n          limits:\n            cpu: "200m"\n            memory: "256Mi"\n          requests:\n            cpu: "100m"\n            memory: "128Mi"/' | \
sed '/securityContext: {}/a \          runAsNonRoot: true\n          privileged: false' | kubectl apply -f -
echo "Created new microservice-deployment with 2 replicas and compliance settings"

# Verify deployment status
echo "Checking deployment status..."
kubectl wait --for=condition=available --timeout=60s deployment/microservice-deployment || { echo "Wait failed: $?"; exit 1; }
echo "Deployment microservice-deployment is ready with 2 replicas"
