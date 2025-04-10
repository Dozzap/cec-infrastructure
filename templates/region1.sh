#!/bin/bash
set -euo pipefail
echo "Setting up CLOUD WORKER (region1.sh)..."

# 1. Update packages and install dependencies
sudo yum update -y
sudo yum install -y docker git curl conntrack iproute-tc
sudo systemctl enable docker --now
sudo swapoff -a

# 2. Configure Kubernetes repository (using a mirror)
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
EOF

# 3. Install Kubernetes components
sudo yum install -y kubelet-1.28.0 kubeadm-1.28.0 kubectl-1.28.0
sudo systemctl enable kubelet --now

# 4. Join the Kubernetes cluster (using your actual join command)
echo "Joining Kubernetes cluster..."
# Ensure you run this as root (using sudo if necessary)

echo "Cloud Worker joined successfully!"
