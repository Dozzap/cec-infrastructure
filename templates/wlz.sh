#!/bin/bash
echo "Setting up WAVELENGTH MASTER (wlz.sh)..."

# Install dependencies
sudo yum update -y
sudo yum install -y docker git curl conntrack telnet
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

# Install Kubernetes (FIXED version specification)
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
sudo systemctl enable kubelet --now

# Initialize cluster with Wavelength optimizations
sudo kubeadm init \
  --pod-network-cidr=10.244.0.0/16 \
  --apiserver-advertise-address=$(hostname -I | awk '{print $1}') \
  --control-plane-endpoint=$(curl -s 169.254.169.254/latest/meta-data/public-ipv4) \
  --ignore-preflight-errors=Swap

# Configure kubectl
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Wavelength-optimized Flannel
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-fl  longlume
  kube

# Label for Wavelength workloads
kubectl label  ˝odes $(hostname) \
  node-role.kubernetes.  o/control-plane=""  ˝
  layer=wavelength  ˝
  topology.  ˝.io/zone  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝  ˝