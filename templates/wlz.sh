# #!/bin/bash
# sudo yum update -y
# sudo yum install -y git
# cd /home/ssm-user

# # Download Docker Compose
# sudo yum install docker containerd screen -y
# # sleep 1
# # wget https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)
# sleep 1
# sudo mv docker-compose-$(uname -s)-$(uname -m) /usr/libexec/docker/cli-plugins/docker-compose
# sleep 1
# chmod +x /usr/libexec/docker/cli-plugins/docker-compose
# sleep 5
# systemctl enable docker.service --now
# sudo usermod -a -G docker ec2-user
# sudo usermod -a -G docker ssm-user


# sudo mkdir -p /mosquitto/config
# sudo mkdir -p /mosquitto/data
# sudo mkdir -p /mosquitto/log

# sudo bash -c 'cat > /mosquitto/config/mosquitto.conf <<EOF
# persistence true
# persistence_location /mosquitto/data/
# log_dest file /mosquitto/log/mosquitto.log
# allow_anonymous true
# listener 1883
# EOF'

# docker run -d -p 1883:1883 -p 9001:9001 -v /mosquitto:/mosquitto eclipse-mosquitto


# docker pull nats

# docker network create nats

# docker run -d --name nats --network nats --rm -p 4222:4222 -p 8222:8222 nats --http_port 8222



# # docker run --init --net=host -p 7447:7447/tcp -p 8050:8000/tcp -e ZENOHD_LISTEN='tcp/0.0.0.0:7447' --name zenoh-server eclipse/zenoh

# # # Build Function
# # cd eco_provider_performance2/functions/first
# # docker compose up --build



# #