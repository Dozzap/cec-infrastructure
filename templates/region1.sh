#!/bin/bash

# Master Node Setup Script for Kubernetes
# Step 1: Update the system
echo "Updating the system..."
sudo yum update -y

# Step 2: Install Docker
echo "Installing Docker..."
sudo yum install -y docker
sudo systemctl enable docker --now
sudo usermod -a -G docker ec2-user

# Step 3: Add Kubernetes repository
echo "Adding Kubernetes repository..."
sudo tee /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key
repo_gpgcheck=1
EOF

# Step 4: Install Kubernetes components
echo "Installing Kubernetes components..."
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

# Step 5: Enable and start kubelet
echo "Enabling and starting kubelet..."
sudo systemctl enable --now kubelet

# Step 6: Initialize Kubernetes cluster
echo "Initializing Kubernetes cluster..."
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Step 7: Configure kubectl for the current user
echo "Configuring kubectl..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=$HOME/.kube/config

# Step 8: Verify kubectl configuration
echo "Verifying kubectl configuration..."
kubectl config view



# Step 10: Verify Kubernetes setup
echo "Verifying Kubernetes setup..."
kubectl get nodes
kubectl get pods --all-namespaces

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=$HOME/.kube/config

kubectl config view


# restart kubenertes services
# sudo systemctl restart kubelet
# kubectl get pods -n kube-system

# restart cluster
# sudo kubeadm reset
# sudo kubeadm init --pod-network-cidr=10.244.0.0/16



# Step 11: Print instructions for worker node setup
echo "Master node setup complete!"

kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=NodePort

kubectl get pods
kubectl get svc nginx


# curl http://<WORKER_NODE_IP>:<NODE_PORT>




