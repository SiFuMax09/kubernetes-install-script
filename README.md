# Kubernetes & Containerd Installation Script

This script automates the installation of Containerd and Kubernetes on a Linux server (tested on Debian/Ubuntu).

## Prerequisites
- Root access on the Linux server.
- Sudo must be installed
- Operating System: Debian/Ubuntu.
- LXC Containers are not supported

## What will be installed
- **Containerd** (Version 2.0.2)
- **runc** (Version 1.2.5)
- **CNI Plugins** (Version 1.6.2)
- **Kubernetes** (kubeadm, kubelet, kubectl, Version 1.32)

## Running the Script

- Download the script:
   ```bash
   curl -s https://raw.githubusercontent.com/SiFuMax09/kubernetes-install-script/refs/heads/main/install.sh | bash
   ```

## What does the script do?

- Permanently disables and removes swap.
- Installs Containerd and configures the Containerd service.
- Installs runc and necessary CNI plugins.
- Installs the latest versions of Kubernetes components (kubeadm, kubelet, kubectl).
- Enables and starts all necessary services automatically.

## After Installation

Once completed, you can either initialize Kubernetes as a new cluster or join an existing one:



- To initialize a new cluster:

   Now you can continue with the initialization of the cluster

   For more Information please consult the Kubernetes Docs at https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
     ```bash
     sudo kubeadm init
     ```
     After you finished initialization of your cluser you need to run these commands to get your kubectl talk to kubelet & kubeadm
     ```bash
     mkdir -p $HOME/.kube
     sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
     sudo chown $(id -u):$(id -g) $HOME/.kube/config
     ```

   You must deploy a Container Network Interface (CNI) based Pod network add-on so that your Pods can communicate with each other. Cluster DNS (CoreDNS) will not start up before a network is installed.

   For that we recomend installing Calico

   ```bash

   kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.2/manifests/tigera-operator.yaml

   kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.2/manifests/custom-resources.yaml
   
   ```


- To join an existing cluster, use the command provided by your cluster master:

  ```bash
  sudo kubeadm join <MASTER_IP>:<PORT> --token <TOKEN> --discovery-token-ca-cert-hash sha256:<HASH>
  ```


- If you want to deploy heml applications you should install it with these commands
   ```bash
   curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
   sudo apt-get install apt-transport-https --yes
   echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
   sudo apt-get update
   sudo apt-get install helm
   ```

- There is also a kubernetes dashboard available for you to install
  - This requires you to have installed Helm CLI (See Step before)
 
  ```bash
  # Add kubernetes-dashboard repository
  helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
  # Deploy a Helm Release named "kubernetes-dashboard" using the kubernetes-dashboard chart
  helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard
  ```
  ### Information about the dashboard
  - ``kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443`` command is required to be run to access the dashboard. This command NEEDS to be ran on your computer after you installed the kubectl on your computer and copied the kube config file. (A tutorial will follow.)
  - To expose the dashboard permanent you need to change the Service ``kubernetes-dashboard-kong-proxy`` type to ``NodePort`` after you done that Kubernetes will redeploy that Service and now your Application is available via the NodePort you can get that from viewing the config again.
 
- For the previous thing to work good you might want to install a loadbalancing system like metallb. For that I am going to use the helm system.
  ```bash
  helm repo add metallb https://metallb.github.io/metallb
  helm install metallb metallb/metallb
  ```

- For having metrics in the dashboard i recommend installing this.
  ```bash
  kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
  ```

## Notes
- The script is optimized for Debian-based systems.
- Always check for newer versions of the software before running the script.

## License
This script is licensed under the MIT License. See the `LICENSE` file for more details.
