#!/bin/bash
echo "Setting up Wavelength WORKER Node..."

# 1. Install dependencies
sudo yum update -y
sudo yum install -y docker git curl conntrack aws-cli
sudo systemctl enable docker --now
sudo swapoff -a

# 2. Configure Kubernetes repository
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

# 4. Retrieve join command from SSM Parameter Store
JOIN_CMD=$(aws ssm get-parameter --name "k8s-wavelength-join-command" --with-decryption --query "Parameter.Value" --output text)
echo "Retrieved join command: $JOIN_CMD"

# 5. Join the Kubernetes cluster
sudo $JOIN_CMD

echo "Wavelength Worker Node setup complete!"
