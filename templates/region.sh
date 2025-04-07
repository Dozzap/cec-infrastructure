#!/bin/bash
echo "Setting up CLOUD MASTER (region.sh)..."

# 1. Install dependencies
sudo yum update -y
sudo yum install -y docker git curl conntrack yum-utils
sudo systemctl enable docker --now


# 2. Configure Kubernetes repo
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key
EOF

# 3. Install Kubernetes components
sudo yum install -y kubelet-1.28.0 kubeadm-1.28.0 kubectl-1.28.0 --disableexcludes=kubernetes
sudo systemctl enable kubelet --now


# NOTE:
# You can now SCP these to a Wavelength node like this:
# scp /home/ec2-user/k8s-rpms/* ec2-user@<WAVELENGTH_IP>:/tmp/k8s-rpms/

# 4. Initialize Kubernetes cluster
sudo kubeadm init \
  --pod-network-cidr=10.244.0.0/16 \
  --apiserver-advertise-address=$(hostname -I | awk '{print $1}') \
  --control-plane-endpoint=$(curl -s 169.254.169.254/latest/meta-data/public-ipv4)

# 5. Configure kubectl
echo "Configuring kubectl..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=$HOME/.kube/config


# 6. Install Flannel CNI
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# 7. Label node
kubectl label nodes $(hostname) \
  node-role.kubernetes.io/control-plane="" \
  layer=cloud \
  topology.kubernetes.io/zone=cloud-1

# 8. Generate worker join command
sudo kubeadm token create --print-join-command > /home/ec2-user/worker-join-command.txt
chmod 600 /home/ec2-user/worker-join-command.txt
echo "Worker join command saved to: /home/ec2-user/worker-join-command.txt"


# 9. Install metrics server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# 10. Set up cross-layer communication (replace with real IPs)
kubectl create configmap cross-layer-config \
  --from-literal=wavelength_endpoint=10.0.10.22\
  --from-literal=edge_endpoint=10.77.160.39

kubectl create namespace cloud
kubectl apply -f cloud-services.yaml
