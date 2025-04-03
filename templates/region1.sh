#!/bin/bash
echo "Setting up CLOUD WORKER (region1.sh)..."

# Install dependencies
sudo yum update -y
sudo yum install -y docker kubelet kubeadm kubectl --disableexcludes=kubernetes
sudo systemctl enable docker kubelet --now

# Get join command from master (replace <MASTER_IP>)
scp ec2-user@ip-10-0-1-84:/home/ec2-user/worker-join-command.txt .

# Join cluster (SIMPLIFIED command)
sudo $(cat worker-join-command.txt) \
  --node-labels="layer=cloud,topology.kubernetes.io/zone=cloud-1"

echo "Worker joined cloud cluster. Verify with:"
echo "kubectl get nodes -l layer=cloud"





