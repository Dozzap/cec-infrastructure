#!/bin/bash
# Cloud Master Node Setup

# Step 1: Update system
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

# Step 5: Initialize Kubernetes Cluster
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Step 6: Configure kubectl
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=$HOME/.kube/config

# Step 7: Install Calico Network Plugin
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml

# Step 8: Deploy Services in Kubernetes
kubectl create deployment conversion --image=dozzap/workflow_published-conversion
kubectl expose deployment conversion --port=5000 --type=ClusterIP

kubectl create deployment profanity --image=dozzap/workflow_published-profanity
kubectl expose deployment profanity --port=5000 --type=ClusterIP

kubectl create deployment censor --image=dozzap/workflow_published-censor
kubectl expose deployment censor --port=5000 --type=ClusterIP

kubectl create deployment compression --image=dozzap/workflow_published-compression
kubectl expose deployment compression --port=5000 --type=ClusterIP

# Step 9: Display Service Information
kubectl get svc
kubectl get pods
