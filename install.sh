sudo swapoff -a
sed -i '/swap/d' /etc/fstab

echo "Swap disabled."

echo "Installing Containerd"

wget "https://github.com/containerd/containerd/releases/download/v2.0.2/containerd-2.0.2-linux-amd64.tar.gz"

tar Cxzvf /usr/local "containerd-2.0.2-linux-amd64.tar.gz"


wget "https://raw.githubusercontent.com/containerd/containerd/main/containerd.service"
mv containerd.service /usr/lib/systemd/system/


wget "https://raw.githubusercontent.com/containerd/containerd/main/containerd.service"
mv containerd.service /etc/systemd/system/

systemctl daemon-reload
systemctl enable --now containerd

wget "https://github.com/opencontainers/runc/releases/download/v1.2.5/runc.amd64"

install -m 755 runc.amd64 /usr/local/sbin/runc

mkdir -p /opt/cni/bin

wget "https://github.com/containernetworking/plugins/releases/download/v1.6.2/cni-plugins-linux-amd64-v1.6.2.tgz"

tar Cxzvf /opt/cni/bin "cni-plugins-linux-amd64-v1.6.2.tgz"

echo "Finished Installing Containerd"

echo "Installing Kubernetes"

sudo apt-get update

sudo apt-get install -y apt-transport-https ca-certificates curl gpg

curl -fsSL "https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key" | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
sysctl net.ipv4.ip_forward

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo systemctl enable --now kubelet
