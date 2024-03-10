#!/bin/bash

echo "Provisioning slave node ...uWu..."

# curl -sfL https://get.k3s.io | K3S_URL="https://192.168.56.110:6443" K3S_TOKEN=`cat /var/www/node-token` sh -
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent --server https://192.168.56.110:6443 --token `cat /var/www/node-token` --node-ip 192.168.56.111" sh -s -

