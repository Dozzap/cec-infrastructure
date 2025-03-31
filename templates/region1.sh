#!/bin/bash
# Cloud Worker Node Setup

echo "Setting up Cloud Worker Node..."

# Step 1: Update the system
sudo yum update -y

# Step 2: Install Docker and Kubernetes
sudo yum install -y docker kubelet kubeadm kubectl

# Step 3: Enable and start Docker and Kubernetes services
sudo systemctl enable docker --now
sudo systemctl enable kubelet --now

# Step 4: Join the Cloud Worker Node to the Kubernetes Master Node (replace <JOIN_COMMAND>)
sudo kubeadm join <JOIN_COMMAND>

# Step 5: Install Docker Compose for service orchestration
echo "Setting up Docker Compose for Cloud Worker"
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Step 6: Create Docker Compose file for Cloud Worker services
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

# Step 7: Run Docker Compose to start services
cd /home/ec2-user
sudo docker-compose up -d

# Cloud Worker setup is complete
echo "Cloud Worker Node setup complete!"
