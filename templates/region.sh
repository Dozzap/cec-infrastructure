#!/bin/bash
set -euo pipefail
echo "Setting up CLOUD MASTER (region.sh)..."

# 1. Update packages and install dependencies
sudo yum update -y
sudo yum install -y docker git curl conntrack yum-utils aws-cli
sudo systemctl enable docker --now

# 2. Configure Kubernetes repository
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

# 4. Initialize Kubernetes cluster (Cloud Master)
MASTER_IP=$(hostname -I | awk '{print $1}')
CONTROL_PLANE_ENDPOINT=$(curl -s 169.254.169.254/latest/meta-data/public-ipv4)
sudo kubeadm init \
  --pod-network-cidr=10.244.0.0/16 \
  --apiserver-advertise-address="$MASTER_IP" \
  --control-plane-endpoint="$CONTROL_PLANE_ENDPOINT"

# 5. Configure kubectl for ec2-user
echo "Configuring kubectl..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=$HOME/.kube/config

# 6. Install Flannel CNI
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# 7. Label this master node as part of the cloud layer
kubectl label nodes "$(hostname)" node-role.kubernetes.io/control-plane="" layer=cloud topology.kubernetes.io/zone=cloud-1

# 8. Generate the worker join command and save it
JOIN_CMD=$(sudo kubeadm token create --print-join-command)
echo "$JOIN_CMD" > /home/ec2-user/worker-join-command.txt
chmod 600 /home/ec2-user/worker-join-command.txt
echo "Worker join command saved to /home/ec2-user/worker-join-command.txt"


# 9. Install Metrics Server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

kubectl create namespace cloud || true

# 10. Create the 'cloud' namespace and deploy additional cloud services (e.g. censor, compression)
cat <<EOF > /home/ec2-user/cloud-services.yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: censor
  namespace: cloud
spec:
  replicas: 2
  selector:
    matchLabels:
      app: censor
  template:
    metadata:
      labels:
        app: censor
    spec:
      nodeSelector:
        layer: cloud
      containers:
      - name: censor
        image: dozzap/workflow_published-censor:latest
        ports:
        - containerPort: 5000
        env:
        - name: MQTT_BROKER
          value: "mosquitto-service.wavelength"
        - name: MQTT_TOPIC_SUB
          value: "pipeline/profanity/out"
        - name: MQTT_TOPIC_PUB
          value: "pipeline/censor/out"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: compression
  namespace: cloud
spec:
  replicas: 2
  selector:
    matchLabels:
      app: compression
  template:
    metadata:
      labels:
        app: compression
    spec:
      nodeSelector:
        layer: cloud
      containers:
      - name: compression
        image: dozzap/workflow_published-compression:latest
        ports:
        - containerPort: 5000
        env:
        - name: MQTT_BROKER
          value: "mosquitto-service.wavelength"
        - name: MQTT_TOPIC_SUB
          value: "pipeline/censor/out"
        - name: MQTT_TOPIC_PUB
          value: "pipeline/compression/out"
---
apiVersion: v1
kind: Service
metadata:
  name: censor-service
  namespace: cloud
spec:
  type: LoadBalancer
  ports:
  - port: 5004
    targetPort: 5000
  selector:
    app: censor
---
apiVersion: v1
kind: Service
metadata:
  name: compression-service
  namespace: cloud
spec:
  type: LoadBalancer
  ports:
  - port: 5005
    targetPort: 5000
  selector:
    app: compression
EOF


kubectl apply -f /home/ec2-user/cloud-services.yaml



echo "Cloud MASTER setup complete!"




echo "$JOIN_CMD"