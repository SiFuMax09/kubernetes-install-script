# EN


# DE
# Kubernetes & Containerd Installation Script

Dieses Skript automatisiert die Installation von Containerd und Kubernetes auf einem Linux-Server (getestet auf Debian/Ubuntu).

## Voraussetzungen
- Root-Zugriff auf den Linux-Server.
- Betriebssystem: Debian/Ubuntu.

## Was installiert wird
- **Containerd** (Version 2.0.2)
- **runc** (Version 1.2.5)
- **CNI Plugins** (Version 1.6.2)
- **Kubernetes** (kubeadm, kubelet, kubectl, Version 1.32)

## Ausführung des Skripts

1. Mach das Skript ausführbar:
   ```bash
   chmod +x install.sh
   ```

2. Starte das Skript als Root oder mit sudo:
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

