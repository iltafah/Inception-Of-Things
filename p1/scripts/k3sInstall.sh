#!/bin/bash



echo "Provisioning virtual machine...uWu...";
sudo systemctl disable firewalld --now

# curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" sh -s - server;
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --write-kubeconfig-mode=644 --node-ip 192.168.56.110"  sh -s -
echo "uWu";
sudo cp /var/lib/rancher/k3s/server/node-token /var/www

