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

## Notes
- The script is optimized for Debian-based systems.
- Always check for newer versions of the software before running the script.

## License
This script is licensed under the MIT License. See the `LICENSE` file for more details.
