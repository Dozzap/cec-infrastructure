#!/bin/bash
# Cloud Worker Node Setup

# Step 1: Update System
sudo yum update -y

# Step 2: Install Docker
sudo yum install -y docker
sudo systemctl enable docker --now
sudo usermod -aG docker ec2-user

# Step 3: Add Kubernetes Repository
sudo tee /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key
repo_gpgcheck=1
EOF

# Step 4: Install Kubernetes
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
sudo systemctl enable --now kubelet

# Step 5: Join the Cluster
sudo kubeadm join 10.0.1.105:6443 --token r0pugv.i6r57mzg9aw76s79 \
        --discovery-token-ca-cert-hash sha256:ae085696b354db4a83718b80019d778c86af30865b7d077df330faf2d36f8881

