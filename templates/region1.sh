#!/bin/bash
echo "Setting up CLOUD WORKER (region1.sh)..."

# Install dependencies
# sudo yum update -y
sudo yum install -y kubelet-1.28.0 kubeadm-1.28.0 kubectl-1.28.0 --disableexcludes=kubernetes
sudo systemctl enable docker kubelet --now
sudo swapoff -a


# Join cluster (SIMPLIFIED command)
kubeadm join 10.0.1.101:6443 --token l59vnt.5iw155qxddryklqb \
        --discovery-token-ca-cert-hash sha256:8a80a29ddea3375082e658a0ed5f00a5914f69ef84797b368ca7d6c1b976b96f \
  --node-labels="layer=cloud,topology.kubernetes.io/zone=cloud-1"

echo "Worker joined cloud cluster. Verify with:"
echo "kubectl get nodes -l layer=cloud"





