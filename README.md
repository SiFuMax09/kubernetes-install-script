# EN
# Kubernetes & Containerd Installation Script

This script automates the installation of Containerd and Kubernetes on a Linux server (tested on Debian/Ubuntu).

## Prerequisites
- Root access on the Linux server.
- Sudo must be installed
- Operating System: Debian/Ubuntu.

## What will be installed
- **Containerd** (Version 2.0.2)
- **runc** (Version 1.2.5)
- **CNI Plugins** (Version 1.6.2)
- **Kubernetes** (kubeadm, kubelet, kubectl, Version 1.32)

## Running the Script

1. Download the script:
   ```bash
   wget https://raw.githubusercontent.com/SiFuMax09/kubernetes-install-script/refs/heads/main/install.sh
   ```
3. Make the script executable:
   ```bash
   chmod +x install.sh
   ```

4. Run the script as root or with sudo:
   ```bash
   sudo ./install.sh
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

  ```bash
  sudo kubeadm init
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



# DE
# Kubernetes & Containerd Installation Script

Dieses Skript automatisiert die Installation von Containerd und Kubernetes auf einem Linux-Server (getestet auf Debian/Ubuntu).

## Voraussetzungen
- Root-Zugriff auf den Linux-Server.
- Sudo muss auf dem Server installiert sein.
- Betriebssystem: Debian/Ubuntu.

## Was installiert wird
- **Containerd** (Version 2.0.2)
- **runc** (Version 1.2.5)
- **CNI Plugins** (Version 1.6.2)
- **Kubernetes** (kubeadm, kubelet, kubectl, Version 1.32)

## Ausführung des Skripts

1. Herunterladen des Scripts:
   ```bash
   wget https://raw.githubusercontent.com/SiFuMax09/kubernetes-install-script/refs/heads/main/install.sh
   ```

2. Mach das Skript ausführbar:
   ```bash
   chmod +x install.sh
   ```

3. Starte das Skript als Root oder mit sudo:
   ```bash
   sudo ./install.sh
   ```

## Was macht das Skript?

- Deaktiviert und entfernt Swap dauerhaft.
- Installiert Containerd und konfiguriert den Containerd-Dienst.
- Installiert runc und die notwendigen CNI-Plugins.
- Installiert die neuesten Versionen von Kubernetes-Komponenten (kubeadm, kubelet, kubectl).
- Aktiviert und startet automatisch alle notwendigen Dienste.

## Nach der Installation

Nach Abschluss kannst du Kubernetes entweder als neuen Cluster initialisieren oder einem bestehenden Cluster beitreten:

- Um einen neuen Cluster zu initialisieren:

  ```bash
  sudo kubeadm init
  ```

- Um einem bestehenden Cluster beizutreten, verwende den vom Master bereitgestellten Befehl:

  ```bash
  sudo kubeadm join <MASTER_IP>:<PORT> --token <TOKEN> --discovery-token-ca-cert-hash sha256:<HASH>
  ```

## Hinweise
- Das Skript ist für Debian-basierte Systeme optimiert.
- Prüfe stets, ob es eine aktuellere Version der verwendeten Software gibt, bevor du das Skript ausführst.

## Lizenz
Dieses Skript ist unter der MIT-Lizenz verfügbar. Siehe die Datei `LICENSE` für weitere Details.

