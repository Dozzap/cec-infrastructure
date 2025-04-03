#!/bin/bash
echo "Setting up Wavelength MASTER (Control Plane)"

# 1. Install dependencies
sudo yum update -y
sudo yum install -y docker git curl conntrack telnet
sudo systemctl enable docker --now

# 2. Configure Kubernetes
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key
EOF

# 3. Install Kubernetes
sudo yum install -y kubelet-1.28.0 kubeadm-1.28.0 kubectl-1.28.0 --disableexcludes=kubernetes
sudo systemctl enable kubelet --now

echo "Configuring kubectl..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=$HOME/.kube/config



# 4. Initialize cluster
sudo kubeadm init \
  --pod-network-cidr=10.244.0.0/16 \
  --apiserver-advertise-address=$(hostname -I | awk '{print $1}') \
  --control-plane-endpoint=$(curl -s 169.254.169.254/latest/meta-data/public-ipv4)

# 5. Configure kubectl
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 6. Install Flannel CNI (optimized for Wavelength)
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# 7. Label master node
kubectl label nodes $(hostname) \
  node-role.kubernetes.io/control-plane="" \
  layer=wavelength \
  topology.kubernetes.io/zone=wlz-1 \
  carrier.wavelength.aws/optimized=true

# 8. Generate worker join command
sudo kubeadm token create --print-join-command > /home/ec2-user/wavelength-worker-join.sh
chmod +x /home/ec2-user/wavelength-worker-join.sh

# 9. Install metrics server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml




echo "Wavelength Master Ready!"
echo "Worker join command saved to: ~/wavelength-worker-join.sh"
echo "Run this on Wavelength Worker Instance B"