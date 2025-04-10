#!/bin/bash
echo "Setting up Wavelength WORKER Node..."

# 1. Update packages and install dependencies
sudo yum update -y
sudo yum install -y docker git curl conntrack aws-cli
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
sudo yum install -y kubelet-1.28.0 kubeadm-1.28.0 kubectl-1.28.0 --disableexcludes=kubernetes
sudo systemctl enable kubelet --now

# 4. Join the Kubernetes cluster for wavelength
echo "Joining Kubernetes cluster..."

echo "Wavelength Worker Node setup complete!"

# Optionally label the node as wavelength
sudo kubectl label node $(hostname) layer=wavelength --overwrite
