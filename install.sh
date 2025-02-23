#!/bin/bash

# Swap deaktivieren
echo -e "\n\033[1;34m--- Swap wird deaktiviert ---\033[0m\n"
sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab
echo -e "\033[1;32mSwap erfolgreich deaktiviert.\033[0m\n"

# Containerd Installation
echo -e "\n\033[1;34m--- Installation von Containerd startet ---\033[0m\n"
wget -q --show-progress "https://github.com/containerd/containerd/releases/download/v2.0.2/containerd-2.0.2-linux-amd64.tar.gz"
tar Cxzvf /usr/local containerd-2.0.2-linux-amd64.tar.gz

# Systemd-Service für Containerd installieren
wget -q --show-progress "https://raw.githubusercontent.com/containerd/containerd/main/containerd.service" -O /etc/systemd/system/containerd.service

sudo systemctl daemon-reload
sudo systemctl enable --now containerd

echo -e "\033[1;32mContainerd erfolgreich installiert und gestartet.\033[0m\n"

# runc Installation
echo -e "\n\033[1;34m--- Installation von runc startet ---\033[0m\n"
wget -q --show-progress "https://github.com/opencontainers/runc/releases/download/v1.2.5/runc.amd64"
sudo install -m 755 runc.amd64 /usr/local/sbin/runc
echo -e "\033[1;32mrunc erfolgreich installiert.\033[0m\n"

# CNI Plugins Installation
echo -e "\n\033[1;34m--- Installation der CNI Plugins startet ---\033[0m\n"
sudo mkdir -p /opt/cni/bin
wget -q --show-progress "https://github.com/containernetworking/plugins/releases/download/v1.6.2/cni-plugins-linux-amd64-v1.6.2.tgz"
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.6.2.tgz
echo -e "\033[1;32mCNI Plugins erfolgreich installiert.\033[0m\n"

# Kubernetes Installation
echo -e "\n\033[1;34m--- Installation von Kubernetes startet ---\033[0m\n"
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

curl -fsSL "https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key" | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

sudo echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo sysctl -w net.ipv4.ip_forward=1
sudo echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo systemctl enable --now kubelet

echo -e "\033[1;32mKubernetes erfolgreich installiert und aktiviert.\033[0m\n"
echo -e "\n\033[1;33m--- Installation vollständig abgeschlossen! ---\033[0m\n"
