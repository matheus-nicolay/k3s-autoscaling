export KUBECONFIG=/home/matheus/.kube/config
kubectl delete node $(kubectl get nodes | grep NotReady | awk '{print $1;}')

#curl -vk --resolve 44.197.108.132:6443:127.0.0.1  https://44.197.108.132:6443/ping