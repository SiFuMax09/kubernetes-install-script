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
- **Kubernetes** (kubeadm, kubelet, kubectl, Version latest)

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

   kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml
   
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

  To use NANO instead of the default editor VI use that command in the terminal
  ``export KUBE_EDITOR=nano``

  To edit the kubernetes-dashboard-kong-proxy service use that command
  ```bash
  kubectl edit svc kubernetes-dashboard-kong-proxy -n kubernetes-dashboard
  ```

  To get access to the dashboard we need to create a new service account with an token.
  ```bash
   # 1. Create a ServiceAccount in the kubernetes-dashboard namespace
   kubectl -n kubernetes-dashboard create serviceaccount admin-user
   
   # 2. Bind the ServiceAccount to the cluster-admin role
   kubectl create clusterrolebinding admin-user \
     --clusterrole=cluster-admin \
     --serviceaccount=kubernetes-dashboard:admin-user
   
   # 3. Create a long-lived token secret linked to the ServiceAccount
   cat <<EOF | kubectl apply -f -
   apiVersion: v1
   kind: Secret
   metadata:
     name: admin-user-token
     namespace: kubernetes-dashboard
     annotations:
       kubernetes.io/service-account.name: "admin-user"
   type: kubernetes.io/service-account-token
   EOF
   
   # 4. Wait a few seconds for the API server to populate the token
   sleep 5
   
   # 5. Retrieve the token and copy it for dashboard login
   kubectl -n kubernetes-dashboard get secret admin-user-token -o jsonpath="{.data.token}" | base64 -d && echo
  ```
  Use the given token to login to the dashboard.
  
- For the previous thing to work good you might want to install a loadbalancing system like metallb. For that I am going to use the helm system.
  ```bash
  helm repo add metallb https://metallb.github.io/metallb
  helm repo update
  ```

  ```bash
  kubectl create namespace metallb-system
  ```

  ```bash
  helm install metallb metallb/metallb -n metallb-system
  ```

   Then you want to create a config for metallb.

   ```
   nano metallb-config.yaml
   ```

   ```yaml
   apiVersion: metallb.io/v1beta1
   kind: IPAddressPool
   metadata:
     name: default-pool
     namespace: metallb-system
   spec:
     addresses:
       - 172.20.0.240-172.20.0.250
   ---
   apiVersion: metallb.io/v1beta1
   kind: L2Advertisement
   metadata:
     name: l2-advert
     namespace: metallb-system
   ```

  ```
  kubectl apply -f metallb-config.yaml
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
