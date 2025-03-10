#!/bin/bash
sudo yum update -y
sudo yum install -y git
cd /home/ssm-user

# Download Docker Compose
sudo yum install docker containerd screen -y
# sleep 1
wget https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)
sleep 1
sudo mv docker-compose-$(uname -s)-$(uname -m) /usr/libexec/docker/cli-plugins/docker-compose
sleep 1
chmod +x /usr/libexec/docker/cli-plugins/docker-compose
sleep 5
systemctl enable docker.service --now
sudo usermod -a -G docker ec2-user
sudo usermod -a -G docker ssm-user

cat <<EOF > /home/ec2-user/nats.conf
# NATS server configuration
max_payload: 10MB
EOF

docker pull nats

docker network create nats


docker run -d --name nats --network nats --rm -p 4222:4222 -p 8222:8222 -v /home/ec2-user/nats.conf:/etc/nats/nats.conf nats --http_port 8222 -c /etc/nats/nats.conf

# docker run -d --name nats --network nats --rm -p 4222:4222 -p 8222:8222 nats --http_port 8222

# docker run -d --name nats --network nats --rm -p 4222:4222 -p 8222:8222 -v /home/ssm-user/nats.conf:/etc/nats/nats.conf nats --http_port 8222 -c /etc/nats/nats.conf



