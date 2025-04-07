#!/bin/bash
echo "Setting up Wavelength WORKER Node..."

# 1. Install dependencies
sudo yum update -y
sudo yum install -y docker git curl conntrack
sudo systemctl enable docker --now
sudo swapoff -a

# 2. Configure Kubernetes repo
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

# 4. Join the Kubernetes cluster (from Wavelength Master)
sudo kubeadm join 10.0.10.22:6443 --token w5uekz.ibdyel13j7qpo9k9 \
  --discovery-token-ca-cert-hash sha256:462b6e18920058e0dbe36111d3d6eab9a94ce2cf8ef44a7234a26b71af3e2899

echo "Wavelength Worker Node setup complete!"


