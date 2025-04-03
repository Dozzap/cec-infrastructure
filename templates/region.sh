#!/bin/bash
echo "Setting up CLOUD MASTER (region.sh)..."

# Install dependencies
sudo yum update -y
sudo yum install -y docker git curl conntrack
sudo systemctl enable docker --now

# Configure Kubernetes
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key
EOF

sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
sudo systemctl enable kubelet --now

echo "Configuring kubectl..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=$HOME/.kube/config


# Initialize cluster (CORRECTED init command)
sudo kubeadm init \
  --pod-network-cidr=10.244.0.0/16 \
  --apiserver-advertise-address=$(hostname -I | awk '{print $1}') \
  --control-plane-endpoint=$(curl -s 169.254.169.254/latest/meta-data/public-ipv4)

# Configure kubectl (FIXED typo in config path)
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Flannel CNI (FIXED URL)
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# Label node
kubectl label nodes $(hostname) \
  node-role.kubernetes.io/control-plane="" \
  layer=cloud \
  topology.kubernetes.io/zone=cloud-1

# Generate worker join command
sudo kubeadm token create --print-join-command > /home/ec2-user/worker-join-command.txt
chmod 600 /home/ec2-user/worker-join-command.txt
echo "Worker join command saved to: /home/ec2-user/worker-join-command.txt"

# Install metrics server 
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Set up cross-layer communication
kubectl create configmap cross-layer-config \
  --from-literal=wavelength_endpoint=<WLZ_MASTER_IP> \
  --from-literal=edge_endpoint=<YOUR_LAPTOP_IP>