cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."registry.lab.k8s.local"]
    endpoint = ["http://registry.lab.k8s.local"]
EOF

## Setup ingress controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# rm -rf ./certs
# mkdir ./certs

# openssl req -newkey rsa:4096 -nodes -sha256 -keyout ./certs/registry.key -x509 -days 365 -out ./certs/registry.crt -subj "/CN=registry.lab.k8s.local"
kubectl create secret tls registry-tls-secret --key ./certs/registry.key --cert ./certs/registry.crt

# openssl req -newkey rsa:4096 -nodes -sha256 -keyout ./certs/ingress.key -x509 -days 365 -out ./certs/ingress.crt -subj "/CN=*.lab.k8s.local"
kubectl create secret tls ingress-tls-secret --key ./certs/ingress.key --cert ./certs/ingress.crt
