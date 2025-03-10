#!/bin/bash

# Add the zenoh repository
echo "deb [trusted=yes] https://download.eclipse.org/zenoh/debian-repo/ /" | sudo tee -a /etc/apt/sources.list > /dev/null

# update the package list
sudo apt-get update -y


sleep 5

# Install Zenoh, Zenoh plugins, and zenohd
sudo apt-get install -y zenoh=0.11.0-stable zenoh-plugin-storage-manager=0.11.0-stable zenohd=0.11.0-stable zenoh-plugin-rest=0.11.0-stable
sleep 5

# Start Zenoh daemon (zenohd)
# RUST_LOG=debug zenohd -l tcp/0.0.0.0:7447
zenohd -l tcp/0.0.0.0:7447
