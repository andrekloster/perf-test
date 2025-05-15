#!/bin/bash

# Variablen
USERNAME="ansible"
HOMEDIR="/home/$USERNAME"
SSH_DIR="$HOMEDIR/.ssh"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"
SUDOERS_FILE="/etc/sudoers.d/$USERNAME"

# SSH-Schlüssel
SSH_PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCpqGsnl4OM2iDZ/k+aDCDQjnKA/wIqJE9qTEIFW9GDmaSMWplqS2fr9LojsRNBEKDF3mfLUhgwXM9gp4VvUkzdrXE7pkeHG2Q2rZ4AzJBDjrtuhIlVtY4j3VEvk53JyLeN1kam9v6cIJ22KKUpo9VtGRyHsck8FhMvsBMWLLwuWwrRfr5O7zd10R0Btp3doUDX+UatiBkoemltgeV97QFQOf27WipGwFmDbSf192yDu3vDjDBA5kg+AxPRw3rU/Z6M+AavxKOkfxTXPQKRHnupi21EkprFbq5hDpyp1qQdnHsy+gR20sOKJlotgagpPp/RVbQeqlL/leCHchVXHxcofe+dgX3jxt9dBTLBUOeOOMJ7jjLNNu/aoS/1bhm+jPUyK3ruC7bewuMdDRhoCV10QstREnVxdf0Ol+W/VcQPqerASH209TB9jlETCYRb2aFTvHp1Y10khw4tBVbLWUNwa7tecIlHKMZN88fvt+Xr6zxe2JYPP2ZZh6vl2nm5WA+b1elVbSmFoH0FuJ3DQwWJwrmhi9Ku528rsHBjGfQRtq4K0h1amqEXfHqf+5SRqUw27Q3c1USBfw3NHyFPnFroLUgbWHweB+TG3uy9zq1ij6tVt6seCukAmOSkPqnqGxp2yjGNp6FFyd556aJ30Yp+qdpE82RkJB53XbAu3zLNrw== andre@domus.local"

# Überprüfung, ob das Skript mit Root-Rechten läuft
if [ "$EUID" -ne 0 ]; then
    echo "Dieses Skript muss mit Root-Rechten ausgeführt werden (sudo)"
    exit 1
fi

# System-Updates
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' upgrade
apt-get clean -y
apt autoremove -y

# Installation von Basispaketen
apt-get install -y sudo python3


# Überprüfung, ob der Benutzer bereits existiert
if id "$USERNAME" &>/dev/null; then
    echo "Benutzer '$USERNAME' existiert bereits."
else
    # Benutzer erstellen
    echo "Erstelle Benutzer '$USERNAME'..."
    useradd -m -k /etc/skel -s /bin/bash "$USERNAME"
    usermod -aG sudo ansible

    if [ $? -eq 0 ]; then
        echo "Benutzer '$USERNAME' wurde erfolgreich erstellt."
    else
        echo "Fehler beim Erstellen des Benutzers '$USERNAME'."
        exit 1
    fi
fi

# Sudoers-Datei erstellen mit NOPASSWD-Berechtigung
echo "Erstelle sudoers-Eintrag für passwortlose sudo-Nutzung..."
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > "$SUDOERS_FILE"

# .ssh Verzeichnis erstellen
if [ ! -d "$SSH_DIR" ]; then
    echo "Erstelle .ssh-Verzeichnis..."
    mkdir -p "$SSH_DIR"

    # Berechtigungen setzen
    chmod 700 "$SSH_DIR"
    chown "$USERNAME:$USERNAME" "$SSH_DIR"
    echo ".ssh-Verzeichnis wurde erstellt."
else
    echo ".ssh-Verzeichnis existiert bereits."
fi

# authorized_keys Datei erstellen und SSH-Schlüssel hinzufügen
echo "Füge SSH-Schlüssel zu authorized_keys hinzu..."
echo "$SSH_PUBLIC_KEY" > "$AUTHORIZED_KEYS"

# Berechtigungen für authorized_keys setzen
chmod 0600 "$AUTHORIZED_KEYS"
chown -R "$USERNAME:$USERNAME" "$AUTHORIZED_KEYS"

echo "SSH-Schlüssel wurde erfolgreich hinzugefügt."

echo "Setup für Benutzer '$USERNAME' abgeschlossen."
echo "Home-Verzeichnis: $HOMEDIR"
echo "SSH-Verzeichnis: $SSH_DIR"
echo "Authorized Keys: $AUTHORIZED_KEYS"
