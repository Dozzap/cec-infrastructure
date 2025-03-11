#!/bin/bash

# Master Node Setup Script for Kubernetes
#  Update the system



echo "Updating the system..."
sudo yum update -y

#  Install Docker
echo "Installing Docker..."
sudo yum install -y docker
sudo systemctl enable docker --now
sudo usermod -a -G docker ec2-user

#  Add Kubernetes repository
echo "Adding Kubernetes repository..."
sudo tee /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key
repo_gpgcheck=1
EOF

#  Install Kubernetes components
echo "Installing Kubernetes components..."
sudo apt install -y kubelet=1.28-00 kubeadm=1.28-00 kubectl=1.28-00 --disableexcludes=kubernetes

# this makes sure that current and future applications will be using the same version 
sudo apt-mark hold kubelet kubeadm kubectl

#  Enable and start kubelet
echo "Enabling and starting kubelet..."
sudo systemctl enable --now kubelet

# Download Docker Compose
sudo yum install docker containerd screen -y
# sleep 1
# wget https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)
sleep 1
sudo mv docker-compose-$(uname -s)-$(uname -m) /usr/libexec/docker/cli-plugins/docker-compose
sleep 1
chmod +x /usr/libexec/docker/cli-plugins/docker-compose
sleep 5
systemctl enable docker.service --now
sudo usermod -a -G docker ec2-user
sudo usermod -a -G docker ssm-user


# create a default config file for docker, that will be used for all nodes
sudo sh -c "containerd config default > /etc/containerd/config.toml"

# this command ensures that kubernetes efficienctly manage system resources for containers
sudo sed -i 's/ SystemdCgroup = false/ SystemdCgroup = true/' /etc/containerd/config.toml

# restarts kubelet service
sudo systemctl restart containerd.service && sudo systemctl restart kubelet.servic

sudo systemctl enable kubelet.service

# download essential components for cluster management and orchestration
sudo kubeadm config images pull

# init master node of cluster
echo "Initializing Kubernetes cluster..."
# set ip address range, NOTE: none for now
# this will then produce a command that looks like the command below and a token, needed for the workers to join the master 
sudo kubeadm init --pod-network-cidr=

# this is the command
echo "Configuring kubectl..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

export KUBECONFIG=$HOME/.kube/config

#  Verify kubectl configuration
echo "Verifying kubectl configuration..."
kubectl config view

#  Install Calico pod network
# this is a network plugin that ensures that the clusters pods can communicate efficiently
# another network plugin components can be used as wanted
echo "Installing Calico pod network..."
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml

# run this command if you have forgotten/lost the token
# this command will generate the whole command that you need to paste to your worker 
kubeadm token create --print-join-command

#  Verify Kubernetes setup
echo "Verifying Kubernetes setup..."
kubectl get nodes
kubectl get pods --all-namespaces

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
export KUBECONFIG=$HOME/.kube/config

kubectl config view


# restart kubenertes services
# sudo systemctl restart kubelet
# kubectl get pods -n kube-system

# restart cluster
# sudo kubeadm reset
# sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# this creates an nginx container node for testing
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=NodePort

# see that status of the worker pod, this will get the age of the pods, the ip and the status
kubectl get pods
kubectl get svc nginx


sudo mkdir -p /mosquitto/config
sudo mkdir -p /mosquitto/data
sudo mkdir -p /mosquitto/log

sudo bash -c 'cat > /mosquitto/config/mosquitto.conf <<EOF
persistence true
persistence_location /mosquitto/data/
log_dest file /mosquitto/log/mosquitto.log
allow_anonymous true
listener 1883
EOF'

docker run -d -p 1883:1883 -p 9001:9001 -v /mosquitto:/mosquitto eclipse-mosquitto


# curl http://<WORKER_NODE_IP>:<NODE_PORT>









