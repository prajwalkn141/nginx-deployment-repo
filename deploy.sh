#!/bin/sh -xe
if ! command -v kubectl &> /dev/null; then
    curl -LO "https://dl.k8s.io/release/v1.31.0/bin/linux/amd64/kubectl"
    chmod +x kubectl
    export PATH=$PATH:$PWD
fi
kubectl create deployment nginx-imperative --image=nginx --replicas=2
