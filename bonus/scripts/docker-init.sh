#!/bin/bash
#install docker
sudo apt-get update -y
sudo apt-get install ca-certificates curl gnupg jq -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -4fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl status docker --no-pager
sudo systemctl restart docker | bash
sudo usermod -aG docker ubuntu
newgrp docker