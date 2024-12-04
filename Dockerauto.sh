#!/bin/bash

# Créer et démarrer le container pour Project-manager
docker run -ti --name Project-manager --hostname Project-manager \
  --network sae502 --ip 192.168.119.22 \
  --add-host RocketChat:192.168.119.23 \
  --add-host TreeInOne:192.168.119.25 \
  --add-host MongoDB:192.168.119.24 \
  ubuntu:24.04

# Créer et démarrer le container pour RocketChat
docker run -ti --name RocketChat --hostname RocketChat \
  --network sae502 --ip 192.168.119.23 \
  ubuntu:24.04

# Pull MongoDB et démarrer le container MongoDB
docker pull mongodb/mongodb-community-server:latest
docker run --name MongoDB --hostname MongoDB \
  -p 27017:27017 --network sae502 --ip 192.168.119.24 \
  -d mongodb/mongodb-community-server:latest

echo "Déploiement terminé."
