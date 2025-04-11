#!/bin/bash
echo "Setting up Wavelength MASTER (Control Plane)..."

# 1. Update packages and install dependencies
sudo yum update -y
sudo yum install -y docker git curl conntrack telnet aws-cli
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

# 4. Initialize Kubernetes cluster (Wavelength Master)
MASTER_IP=$(hostname -I | awk '{print $1}')
CONTROL_PLANE_ENDPOINT=$(curl -s 169.254.169.254/latest/meta-data/public-ipv4)
echo "Master IP: $MASTER_IP"
echo "Control Plane Endpoint: $CONTROL_PLANE_ENDPOINT"

sudo kubeadm init \
  --pod-network-cidr=10.244.0.0/16 \
  --apiserver-advertise-address="$MASTER_IP" \
  --control-plane-endpoint="$CONTROL_PLANE_ENDPOINT"

# 5. Configure kubectl for ec2-user
echo "Configuring kubectl..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 6. Install Flannel CNI (for cluster networking)
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# 7. Label the master node as wavelength
kubectl label nodes "$(hostname)" node-role.kubernetes.io/control-plane="" layer=wavelength topology.kubernetes.io/zone=wlz-1 carrier.wavelength.aws/optimized=true

# 8. Generate the worker join command and save it to a file
JOIN_CMD=$(sudo kubeadm token create --print-join-command)
echo "$JOIN_CMD" | sudo tee /home/ec2-user/wavelength-worker-join.sh
sudo chmod 600 /home/ec2-user/wavelength-worker-join.sh
echo "Wavelength Worker join command saved to /home/ec2-user/wavelength-worker-join.sh"

# 9. Install Metrics Server (optional)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# 10. Create the 'wavelength' namespace if not exists and deploy wavelength-specific services
kubectl create namespace wavelength || true
kubectl apply -f /home/ec2-user/wlz-services.yaml

cat <<EOF | sudo tee /home/ec2-user/wlz-services.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mosquitto-config
  namespace: wavelength
data:
  mosquitto.conf: |
    listener 1883
    allow_anonymous true
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mosquitto
  namespace: wavelength
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mosquitto
  template:
    metadata:
      labels:
        app: mosquitto
    spec:
      containers:
      - name: mosquitto
        image: eclipse-mosquitto:latest
        ports:
        - containerPort: 1883
          hostPort: 1883
        volumeMounts:
        - name: config-volume
          mountPath: /mosquitto/config
      volumes:
      - name: config-volume
        configMap:
          name: mosquitto-config
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: conversion
  namespace: wavelength
spec:
  replicas: 2
  selector:
    matchLabels:
      app: conversion
  template:
    metadata:
      labels:
        app: conversion
    spec:
      nodeSelector:
        layer: wavelength
      containers:
      - name: conversion
        image: dozzap/workflow_published-conversion:latest
        ports:
        - containerPort: 5000
        env:
        - name: MQTT_BROKER
          value: "mosquitto-lb"
        - name: MQTT_TOPIC_SUB
          value: "pipeline/tts/out"
        - name: MQTT_TOPIC_PUB
          value: "pipeline/conversion/out"
---
apiVersion: v1
kind: Service
metadata:
  name: conversion-service
  namespace: wavelength
spec:
  type: ClusterIP
  ports:
    - port: 5002
      targetPort: 5000
  selector:
    app: conversion
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: profanity
  namespace: wavelength
spec:
  replicas: 2
  selector:
    matchLabels:
      app: profanity
  template:
    metadata:
      labels:
        app: profanity
    spec:
      nodeSelector:
        layer: wavelength
      containers:
      - name: profanity
        image: dozzap/workflow_published-profanity:latest
        ports:
        - containerPort: 5000
        env:
        - name: MQTT_BROKER
          value: "mosquitto-lb"
        - name: MQTT_TOPIC_SUB
          value: "pipeline/conversion/out"
        - name: MQTT_TOPIC_PUB
          value: "pipeline/profanity/out"
---
apiVersion: v1
kind: Service
metadata:
  name: profanity-service
  namespace: wavelength
spec:
  type: ClusterIP
  ports:
    - port: 5003
      targetPort: 5000
  selector:
    app: profanity
EOF

echo "Wavelength MASTER setup complete!"
echo "Worker join command:"
echo "$JOIN_CMD"
