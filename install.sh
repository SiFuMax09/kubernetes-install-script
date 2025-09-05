#!/bin/bash
set -e

function check_success() {
    if [ $? -eq 0 ]; then
        echo -e "\033[1;32m$1 erfolgreich.\033[0m"
    else
        echo -e "\033[1;31mFehler bei: $1\033[0m"
        exit 1
    fi
}

# Swap deaktivieren
echo -e "\n\033[1;34m--- Swap wird deaktiviert ---\033[0m\n"
swapoff -a
check_success "swapoff -a"

sed -i '/swap/d' /etc/fstab
check_success "Entfernen von Swap-Einträgen aus /etc/fstab"

# Containerd Installation
echo -e "\n\033[1;34m--- Installation von Containerd startet ---\033[0m\n"
wget -q --show-progress "https://github.com/containerd/containerd/releases/download/v2.1.4/containerd-2.1.4-linux-amd64.tar.gz"
check_success "Download von containerd"
tar Cxzvf /usr/local containerd-2.1.4-linux-amd64.tar.gz
check_success "Entpacken von containerd"

wget -q --show-progress "https://raw.githubusercontent.com/containerd/containerd/main/containerd.service" -O /etc/systemd/system/containerd.service
check_success "Download des containerd systemd-Services"

systemctl daemon-reload
systemctl enable --now containerd
check_success "Starten von containerd"

# runc Installation
echo -e "\n\033[1;34m--- Installation von runc startet ---\033[0m\n"
wget -q --show-progress "https://github.com/opencontainers/runc/releases/download/v1.3.0/runc.amd64"
check_success "Download von runc"
install -m 755 runc.amd64 /usr/local/sbin/runc
check_success "Installation von runc"

# CNI Plugins Installation
echo -e "\n\033[1;34m--- Installation der CNI Plugins startet ---\033[0m\n"
mkdir -p /opt/cni/bin
wget -q --show-progress "https://github.com/containernetworking/plugins/releases/download/v1.8.0/cni-plugins-linux-amd64-v1.8.0.tgz"
check_success "Download der CNI Plugins"
tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.8.0.tgz
check_success "Installation der CNI Plugins"

# Kubernetes Installation
echo -e "\n\033[1;34m--- Installation von Kubernetes startet ---\033[0m\n"
apt-get update
check_success "apt-get update"

apt-get install -y apt-transport-https ca-certificates curl gpg
check_success "Installation von Abhängigkeiten"

curl -fsSL "https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key" | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
check_success "Kubernetes Repo-Key importieren"

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /' > /etc/apt/sources.list.d/kubernetes.list
check_success "Kubernetes Repository eintragen"

sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p
check_success "IP-Forwarding aktivieren"

apt-get update
apt-get install -y kubelet kubeadm kubectl
check_success "Installation von kubelet, kubeadm und kubectl"

apt-mark hold kubelet kubeadm kubectl
check_success "Kubernetes-Pakete auf hold setzen"

systemctl enable --now kubelet
check_success "Starten des kubelet-Dienstes"

echo -e "\033[1;32mKubernetes erfolgreich installiert und aktiviert.\033[0m\n"
echo -e "\n\033[1;33m--- Installation vollständig abgeschlossen! ---\033[0m\n"
