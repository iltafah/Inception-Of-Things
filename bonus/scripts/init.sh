#!/bin/bash
# install k3d
sudo wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64
# install kubectl
sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo chmod +x kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
#gitlab instalation
k3d cluster create gitlab -p 8888:80@loadbalancer 
kubectl create namespace gitlab 
wget https://get.helm.sh/helm-v3.7.1-linux-amd64.tar.gz
tar -zxvf helm-v3.7.1-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm upgrade --install gitlab gitlab/gitlab \
  -n gitlab \
  -f ../confs/values.yaml\
  --set global.hosts.domain=k3d.gitlab.com \
  --set global.hosts.externalIP=0.0.0.0 \
  --set global.hosts.https=false \
  --timeout 600s
kubectl wait --for=condition=ready --timeout=1200s pod -l app=webservice -n gitlab  
pswd=$(kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath="{.data.password}" | base64 --decode)
ip=$(curl ifconfig.me)

echo "127.0.0.1 gitlab.k3d.gitlab.com" | sudo tee -a /etc/hosts
nohup kubectl port-forward service/gitlab-webservice-default  -n gitlab --address 0.0.0.0 5555:8181 > /dev/null 2>&1 &

git clone https://github.com/hskhh/iqessam.git
cd iqessam

git remote add gitlab http://root:${pswd}@${ip}:5555/root/iqessam.git
git push gitlab 
export GITLAB_URL="http://root:${pswd}@${ip}:5555/root/iqessam.git"
cd .. 
# create namespaces
kubectl create namespace dev
kubectl create namespace argocd
# install argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# apply argocd ingress
sed -i "s|GITLAB_URL|`echo $GITLAB_URL`|g" ../confs/application.yml
kubectl apply -f ../confs/application.yml
echo "argocd server is running on http://${ip}:8880"
kubectl wait --for=condition=ready --timeout=1200s pod -l app.kubernetes.io/name=argocd-server -n argocd
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d > /home/ubuntu/argocd.txt
echo "argocd password is $(cat /home/ubuntu/argocd.txt)"
echo "gitlab password is $pswd"
kubectl port-forward svc/argocd-server -n argocd 8880:443 --address 0.0.0.0
