#!/bin/bash

# Vérification si le script est exécuté en tant que root
if [ "$(id -u)" -ne 0 ]; then
  echo "Veuillez exécuter ce script en tant que root ou avec sudo."
  exit 1
fi

echo "Étape 1 : Mise à jour des paquets existants..."
apt-get update -y

echo "Étape 2 : Installation des paquets nécessaires pour Docker..."
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    gnupg

echo "Étape 3 : Ajout de la clé GPG officielle de Docker..."
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "Étape 4 : Ajout du dépôt Docker aux sources de paquets..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Étape 5 : Mise à jour des paquets pour inclure le dépôt Docker..."
apt-get update -y

echo "Étape 6 : Installation de Docker..."
apt-get install -y docker-ce docker-ce-cli containerd.io

echo "Vérification de l'installation de Docker..."
docker --version

if [ $? -eq 0 ]; then
  echo "Docker a été installé avec succès."
else
  echo "Une erreur s'est produite lors de l'installation de Docker."
  exit 1
fi

echo "Étape 7 : Ajout de l'utilisateur actuel au groupe Docker..."
usermod -aG docker ${USER}

# Recharger les groupes pour éviter le redémarrage
echo "Activation du groupe Docker pour l'utilisateur sans redémarrage..."
newgrp docker <<EOF
echo "Docker est prêt à être utilisé sans redémarrage."
EOF

echo "Étape 8 : Installation de Docker Compose..."
# Installer Docker Compose depuis GitHub
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

echo "Vérification de l'installation de Docker Compose..."
docker-compose --version

if [ $? -eq 0 ]; then
  echo "Docker Compose a été installé avec succès."
else
  echo "Une erreur s'est produite lors de l'installation de Docker Compose."
  exit 1
fi

echo "Installation de Docker et Docker Compose terminée ! Vous pouvez maintenant utiliser Docker et Docker Compose sans sudo."
