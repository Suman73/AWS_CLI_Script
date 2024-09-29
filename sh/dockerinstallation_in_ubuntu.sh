#!/bin/bash

# Update the package index
sudo apt update

# Install required packages
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add the Docker repository to APT sources
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update the package index again
sudo apt update

# Install Docker
sudo apt install -y docker-ce

# Start Docker and enable it to run at startup
sudo systemctl start docker
sudo systemctl enable docker

# Verify Docker installation
sudo docker --version
