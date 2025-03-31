#!/bin/bash
# Cloud Master Node Setup

echo "Setting up Cloud Master Node..."

# Step 1: Update the system
sudo yum update -y

# Step 2: Install Docker and Kubernetes
sudo yum install -y docker kubelet kubeadm kubectl

# Step 3: Enable and start Docker and Kubernetes services
sudo systemctl enable docker --now
sudo systemctl enable kubelet --now

# Step 4: Initialize Kubernetes Master Node
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Step 5: Set up kubectl config for user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Step 6: Install Calico network plugin (for pod networking)
kubectl apply -f https://docs.projectcalico.org/v3.26/manifests/calico.yaml

# Step 7: Setup Docker Compose for microservices orchestration
echo "Setting up Docker Compose for Cloud Master"
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Step 8: Create Docker Compose file for Cloud services
cat <<EOF > /home/ec2-user/docker-compose.yml
version: "3.8"
services:
  compression:
    image: dozzap/workflow_published-compression:latest
    ports:
      - "5005:5000"
  
  censor:
    image: dozzap/workflow_published-censor:latest
    ports:
      - "5004:5000"
EOF

# Step 9: Run Docker Compose to start services
cd /home/ec2-user
sudo docker-compose up -d

# Cloud Master setup is complete
echo "Cloud Master Node setup complete!"
