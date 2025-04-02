#!/bin/bash
echo "Setting up Wavelength WORKER Node..."

# 1. Install same dependencies as master
sudo yum update -y
sudo yum install -y docker git curl conntrack
sudo systemctl enable docker --now

# 2. Configure Kubernetes repo (same as master)
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key
EOF

# 3. Install Kubernetes components
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
sudo systemctl enable kubelet --now

# 4. Join cluster (use command from master's ~/wavelength-worker-join.sh)
# This should look like:
# kubeadm join <MASTER_IP>:6443 --token <TOKEN> --discovery-token-ca-cert-hash <HASH>
sudo /home/ec2-user/wavelength-worker-join.sh \
  --node-labels="layer=wavelength,topology.kubernetes.io/zone=wlz-1,carrier.wavelength.aws/optimized=true"

# 5. Verify
echo "Node registration status:"
kubectl get nodes -l layer=wavelength