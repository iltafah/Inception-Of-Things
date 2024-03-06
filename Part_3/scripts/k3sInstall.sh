#!/bin/bash



echo "Provisioning virtual machine...uWu...";
sudo systemctl disable firewalld --now;

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --write-kubeconfig-mode=644 --node-ip 192.168.42.110"  sh -s -;
sleep 10;
kubectl apply -f /var/www/app-one.yaml;
kubectl apply -f /var/www/app-two.yaml;
kubectl apply -f /var/www/app-three.yaml;
