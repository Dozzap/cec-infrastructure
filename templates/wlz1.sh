#!/bin/bash
echo "Setting up Wavelength WORKER Node..."

# Ensure running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# 1. Update packages and install dependencies
yum update -y
yum install -y docker git curl conntrack aws-cli

# 2. Enable Docker and disable swap (K8s requirement)
systemctl enable docker --now
swapoff -a

# 3. Enable Docker Remote API on port 2375 (insecure for dev only!)
mkdir -p /etc/systemd/system/docker.service.d
cat <<EOF > /etc/systemd/system/docker.service.d/override.conf
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2375
EOF

# Reload systemd and restart Docker
systemctl daemon-reexec
systemctl daemon-reload
systemctl restart docker

# 4. Configure Kubernetes repo (Aliyun mirror)
cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
EOF

# 5. Install Kubernetes components
yum install -y kubelet-1.28.0 kubeadm-1.28.0 kubectl-1.28.0 --disableexcludes=kubernetes
systemctl enable kubelet --now

# 6. Join the cluster (replace this line with actual join command)
echo "Joining Kubernetes cluster..."
# kubeadm join <control-plane-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>

echo " Wavelength Worker Node setup complete!"
echo "Remote Docker access available at: tcp://<wavelength-ip>:2375 (insecure)"
