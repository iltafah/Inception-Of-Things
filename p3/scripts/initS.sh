#!/bin/bash
sudo apt-get update -y
sudo apt-get install ca-certificates curl gnupg jq -y
sudo apt-key add gpg || true 
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
sudo usermod -aG docker iqessam
#05-03
# install k3d
sudo wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64
# install kubectl 
sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo chmod +x kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
#cluster creation
sudo k3d cluster create mycluster -p 8888:80@loadbalancer
# create namespaces
sudo kubectl create namespace dev
sudo kubectl create namespace argocd
# install argocd
sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
# apply argocd ingress
sudo kubectl apply  -n argocd -f ../confs/application.yml
echo "argocd server is running on http://localhost:8880"
sleep 5
sudo kubectl wait --for=condition=ready --timeout=1200s pod -l app.kubernetes.io/name=argocd-server -n argocd
sudo kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d > /home/iqessam/Desktop/argocd.txt
sudo kubectl port-forward svc/argocd-server -n argocd 8880:443 
 