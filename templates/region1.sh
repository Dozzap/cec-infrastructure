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

# 2. Enable and start Docker
systemctl enable docker --now
swapoff -a

# 3. Enable Docker Remote API on port 2375 (non-TLS for dev only!)
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

# 4. Add firewall rule (for Amazon Linux, if needed)
# (You can skip this if using AWS security groups instead)
# firewall-cmd --permanent --add-port=2375/tcp
# firewall-cmd --reload

# 5. Kubernetes setup (unchanged)
cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
EOF

yum install -y kubelet-1.28.0 kubeadm-1.28.0 kubectl-1.28.0 --disableexcludes=kubernetes
systemctl enable kubelet --now

# 6. Join Kubernetes cluster (replace this with real join cmd if needed)
echo "Joining Kubernetes cluster..."
# kubeadm join <control-plane-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>

echo "Wavelength Worker Node setup complete!"
echo "Remote Docker accessible via tcp://<this-node-ip>:2375 (insecure mode)"
