#!/bin/bash

# Run this as the root user
if [[ $(/usr/bin/id -u) -ne 0 ]]
then
  echo "Not running as root, please become the root user"
  exit
fi

cd /etc/kubernetes/;  ln -s ssl pki;
/usr/local/bin/kubeadm alpha certs renew apiserver
/usr/local/bin/kubeadm alpha certs renew apiserver-kubelet-client
/usr/local/bin/kubeadm alpha certs renew front-proxy-client

cd /etc/kubernetes
/usr/local/bin/kubeadm alpha kubeconfig user --org system:masters --client-name kubernetes-admin  > admin.conf
/usr/local/bin/kubeadm alpha kubeconfig user --client-name system:kube-controller-manager > controller-manager.conf
/usr/local/bin/kubeadm alpha kubeconfig user --org system:nodes --client-name system:node:$(hostname) > kubelet.conf
/usr/local/bin/kubeadm alpha kubeconfig user --client-name system:kube-scheduler > scheduler.conf

systemctl restart docker
systemctl restart kubelet

cp /root/.kube/config /root/.kube/config.old
cp /etc/kubernetes/admin.conf /root/.kube/config

cp /opt/turbonomic/.kube/config /opt/turbonomic/.kube/config.old
cp /etc/kubernetes/admin.conf /opt/turbonomic/.kube/config
chown turbo.turbo /opt/turbonomic/.kube/config
sed -i '/user: kubernetes-admin/a \    namespace: turbonomic' /opt/turbonomic/.kube/config
