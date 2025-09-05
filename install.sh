#!/bin/bash
set -e

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "\033[1;31mDieses Script muss als root ausgeführt werden. Bitte verwenden Sie 'sudo'.\033[0m" 
   exit 1
fi

# Preserve environment variables and ensure proper PATH
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export DEBIAN_FRONTEND=noninteractive

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
# Use sudo explicitly for swapon command to ensure permissions
if sudo swapon --summary | grep -q '^'; then
    sudo swapoff -a
    check_success "swapoff -a"
else
    echo -e "\033[1;33mKein aktiver Swap gefunden – überspringe swapoff.\033[0m"
fi

sudo sed -i '/swap/d' /etc/fstab
check_success "Entfernen von Swap-Einträgen aus /etc/fstab"

# Containerd Installation
echo -e "\n\033[1;34m--- Installation von Containerd startet ---\033[0m\n"
wget -q --show-progress "https://github.com/containerd/containerd/releases/download/v2.1.4/containerd-2.1.4-linux-amd64.tar.gz"
check_success "Download von containerd"
sudo tar Cxzvf /usr/local containerd-2.1.4-linux-amd64.tar.gz
check_success "Entpacken von containerd"

sudo wget -q --show-progress "https://raw.githubusercontent.com/containerd/containerd/main/containerd.service" -O /etc/systemd/system/containerd.service
check_success "Download des containerd systemd-Services"

sudo systemctl daemon-reload
sudo systemctl enable --now containerd
check_success "Starten von containerd"

# runc Installation
echo -e "\n\033[1;34m--- Installation von runc startet ---\033[0m\n"
wget -q --show-progress "https://github.com/opencontainers/runc/releases/download/v1.3.0/runc.amd64"
check_success "Download von runc"
sudo install -m 755 runc.amd64 /usr/local/sbin/runc
check_success "Installation von runc"

# CNI Plugins Installation
echo -e "\n\033[1;34m--- Installation der CNI Plugins startet ---\033[0m\n"
sudo mkdir -p /opt/cni/bin
wget -q --show-progress "https://github.com/containernetworking/plugins/releases/download/v1.8.0/cni-plugins-linux-amd64-v1.8.0.tgz"
check_success "Download der CNI Plugins"
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.8.0.tgz
check_success "Installation der CNI Plugins"

# Kubernetes Installation
echo -e "\n\033[1;34m--- Installation von Kubernetes startet ---\033[0m\n"
sudo apt-get update
check_success "apt-get update"

sudo apt-get install -y apt-transport-https ca-certificates curl gpg
check_success "Installation von Abhängigkeiten"

# Create keyring directory if it doesn't exist
sudo mkdir -p /etc/apt/keyrings

curl -fsSL "https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key" | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
check_success "Kubernetes Repo-Key importieren"

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
check_success "Kubernetes Repository eintragen"

sudo sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
check_success "IP-Forwarding aktivieren"

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
check_success "Installation von kubelet, kubeadm und kubectl"

sudo apt-mark hold kubelet kubeadm kubectl
check_success "Kubernetes-Pakete auf hold setzen"

sudo systemctl enable --now kubelet
check_success "Starten des kubelet-Dienstes"

echo -e "\033[1;32mKubernetes erfolgreich installiert und aktiviert.\033[0m\n"
echo -e "\n\033[1;33m--- Installation vollständig abgeschlossen! ---\033[0m\n"
