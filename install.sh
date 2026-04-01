#!/bin/bash
set -euo pipefail

# --- Root Check ---
if [[ $EUID -ne 0 ]]; then
   echo -e "\033[1;31mDieses Script muss als root ausgeführt werden.\033[0m"
   exit 1
fi

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export DEBIAN_FRONTEND=noninteractive

function step() {
  echo -e "\n\033[1;34m--- $1 ---\033[0m\n"
}

function ok() {
  echo -e "\033[1;32m✔ $1 erfolgreich.\033[0m"
}

function latest_github_release() {
  curl -s "https://api.github.com/repos/$1/releases/latest" | grep tag_name | cut -d '"' -f4
}

# ================================
# VERSION PROMPT
# ================================

echo -e "\033[1;36mVersion Setup (leer = latest)\033[0m"

CONTAINERD_VERSION=""
RUNC_VERSION=""
CNI_VERSION=""

read -rp "Containerd Version (z.B. v2.1.4): " CONTAINERD_VERSION || true
read -rp "runc Version (z.B. v1.3.0): " RUNC_VERSION || true
read -rp "CNI Plugins Version (z.B. v1.8.0): " CNI_VERSION || true

if [[ -z "$CONTAINERD_VERSION" ]]; then
  CONTAINERD_VERSION=$(latest_github_release containerd/containerd)
fi

if [[ -z "$RUNC_VERSION" ]]; then
  RUNC_VERSION=$(latest_github_release opencontainers/runc)
fi

if [[ -z "$CNI_VERSION" ]]; then
  CNI_VERSION=$(latest_github_release containernetworking/plugins)
fi

echo -e "\n\033[1;33mVerwendete Versionen:\033[0m"
echo "containerd: $CONTAINERD_VERSION"
echo "runc:       $RUNC_VERSION"
echo "cni:        $CNI_VERSION"

# ================================
# SWAP DISABLE
# ================================

step "Swap wird deaktiviert"

if swapon --summary | grep -q '^'; then
    swapoff -a
    ok "swapoff"
else
    echo -e "\033[1;33mKein aktiver Swap gefunden – überspringe.\033[0m"
fi

sed -i '/swap/d' /etc/fstab
ok "Swap aus fstab entfernt"

# ================================
# CONTAINERD
# ================================

step "Containerd installieren"

wget -q --show-progress \
"https://github.com/containerd/containerd/releases/download/${CONTAINERD_VERSION}/containerd-${CONTAINERD_VERSION#v}-linux-amd64.tar.gz"

tar Cxzvf /usr/local containerd-${CONTAINERD_VERSION#v}-linux-amd64.tar.gz

wget -q https://raw.githubusercontent.com/containerd/containerd/main/containerd.service \
-O /etc/systemd/system/containerd.service

systemctl daemon-reload
systemctl enable --now containerd

ok "containerd installiert"

# ================================
# RUNC
# ================================

step "runc installieren"

wget -q --show-progress \
"https://github.com/opencontainers/runc/releases/download/${RUNC_VERSION}/runc.amd64"

install -m 755 runc.amd64 /usr/local/sbin/runc

ok "runc installiert"

# ================================
# CNI
# ================================

step "CNI Plugins installieren"

mkdir -p /opt/cni/bin

wget -q --show-progress \
"https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-amd64-${CNI_VERSION}.tgz"

tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-${CNI_VERSION}.tgz

ok "CNI installiert"

# ================================
# KUBERNETES
# ================================

step "Kubernetes installieren"

apt-get update
apt-get install -y apt-transport-https ca-certificates curl gpg

mkdir -p /etc/apt/keyrings

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key \
  | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' \
  > /etc/apt/sources.list.d/kubernetes.list

sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

systemctl enable --now kubelet

ok "Kubernetes installiert"

echo -e "\n\033[1;32m=== Installation abgeschlossen ===\033[0m\n"
