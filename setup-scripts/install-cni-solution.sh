#!/bin/sh
set -x

# There are multiple solution available for CNI.
# Adding most popular options here
# Please choose based on your needs

# Install WEAVE as CNI
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"


# Install CALICO as CNI
#kubectl apply -f "https://docs.projectcalico.org/manifests/calico.yaml"

# Install FLANNEL as CNI
#kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml