# Projet SAE5.02 SALA Mattéo BUT3 RT : Déployer rocket chat avec la base donné MongoDB

***

**Prérequis avoir Docker !**

**Création des Vm's souus docker :**

    Utilisation du fichier https://vscode.dev/github/Holo-Prism/SAE5.02/blob/main/Dockerauto.sh

    Il va déployer 3 Vm's , le gestionnaire de noeud, MongoDB et RocketChat

**Sur les Vm's Project-manager et RocketChat il faut executer les commandes suivantes afin d'installer ssh :**

    apt update
    apt innstall openssh-server

    Changer le mot de passe root : passwd root

    modifier le fichier ssh pour autoriser la connexion avec root "PermitRootLogin yes" : nano /etc/ssh/sshd_config

    service ssh start

**Sur la Vm MongoDB :**

    Il va falloir activer la réplication pour un chat en temps réel :

    rs.initiate()

    et il faut crée la base rocketchat :

    use rocketchat

    Attention nne pas fermer rocketchat avant d'avoir lancer le playbook ! Si aucune données n'est rentrer MongoDB ne crée pas les base, lorque le playbook aura installer rocket, il remplira la base de données automatiquement. A la fin de l'installation vous pourrez fermer sans soucis.

**Sur la Vm Project-manager :**

    Il va falloir générer une clef ssh pour pouvoir utiliser ansible.

    ssh-keygen (on ne met pas de mdp, pour la sécurité il faudrait en mettre une)

    Il va falloir copier la clef sur la machine distante : 

    ssh-copy-id root@<IP RocketChat ou sont nom> (initier une première connexion ssh avec cette clef pouur ne pas avvoir de problèmes après !)

    

    Installation de ansible : 
        
        apt install python3-virtualenv sshpass
                
        virtualenv ansible --> crée l'environnement ansible
        
        source ansible/bin/activate --> pour utiliser l'environnement virtuel ansible
        
        pip install ansible passlib --> installe ansible
    

**Lancer le playbook :**

    Aller dans l'environnement virtuel ansible : source ansible/bin/activate

    Dossier GitHub : git clone https://github.com/Holo-Prism/SAE5.02.git

    lancer le playbook avec : ansible-playbook -i SAE5.02/inventaire.ini SAE5.02/roles/tasks/rocketchat.yml


Sa y est il ne vous reste plus qu'a vous connecter à l'interface d'administartion : http://192.18.119.23:3000

    Crée le compte admin et paramétrer l'esapace de travail

Sur un client :

    Installer rocketchat et connecter vous à votre espace de travail.


_______________________________________________________________________________________


# Cahier des charges


Mettre en œuvre un système de chat instantané (Rocket.Chat) avec une authentification sécurisée, déployé sur des serveurs Linux et/ou Windows, tout en utilisant Ansible pour automatiser l’installation et la configuration, afin d’assurer la sécurité des utilisateurs et des données. La ou les machine Windows disposeront de WinRM afin de pouvoir utiliser ansible sur ses machines.
 

Composante requise : 

    Serveur DNS (Dédié)

        Description : Gère la résolution des noms de domaine, essentiel pour la communication entre les services.
        Système d'exploitation recommandé : Ubuntu Server ou CentOS.
        Ressources recommandées : 1 CPU, 1 Go de RAM, 10 Go d'espace disque.
        Lien : Permet aux autres serveurs (LDAP, Rocket.Chat, MongoDB) de se trouver facilement via des noms de domaine au lieu d'adresses IP.

    Serveur Active Directory (AD) (Dédié)
        Description : Gère les utilisateurs, groupes et autorisations dans un réseau Windows.
        Système d'exploitation recommandé : Windows Server (dernière version).
        Ressources recommandées : 2 CPU, 4 Go de RAM, 40 Go d'espace disque.
        Lien : Fournit des informations d'authentification aux utilisateurs qui se connectent via LDAP.

    Serveur LDAP (Dédié)
        Description : Service pour gérer l'authentification des utilisateurs via LDAP.
        Système d'exploitation recommandé : Ubuntu Server ou CentOS.
        Ressources recommandées : 1 CPU, 2 Go de RAM, 10 Go d'espace disque.
        Lien : Utilisé par Rocket.Chat pour l'authentification des utilisateurs. Il interagit directement avec Active Directory pour valider les identités.

    Serveur Principal (Rocket.Chat)
        Description : Serveur sur lequel l'application Rocket.Chat sera déployée.
        Système d'exploitation recommandé : Ubuntu (version LTS) ou CentOS.
        Ressources recommandées : 2 CPU, 4 Go de RAM, 20 Go d'espace disque.
        Lien : Communique avec le serveur LDAP pour l'authentification des utilisateurs et avec MongoDB pour le stockage des données des chats.

    Serveur MongoDB
        Description : Serveur pour héberger la base de données NoSQL utilisée par Rocket.Chat.
        Ressources recommandées : 2 CPU, 4 Go de RAM, 20 Go d'espace disque.
        Lien : Stocke toutes les données de Rocket.Chat, y compris les messages, les utilisateurs, et les configurations. Rocket.Chat se connecte à MongoDB pour accéder et gérer ces données.

Les composants pourront être installés sur une ou plusieurs machines ou des OS différents en fonction des besoins et des prérequis (exemple : AD sur windows).
 
Prérequis :
 

    Accès SSH : Accès sécurisé à chaque serveur pour le déploiement.
    Ansible : Installation d’Ansible sur une machine de contrôle pour automatiser le déploiement.
    Infrastructure réseau : Assurer que tous les serveurs peuvent communiquer entre eux via le réseau local.

 
 
Mise en place des services via les playbooks ansible
Dans un dossier rôles, une arborescence sera créée. Un dossier par service/fonctionnalité, qui contiendra les fichiers de configurations, des rôle ou variable commune, ... . L'installation des services se fera depuis un fichier yml afin de déployer l'ensemble de la maquette.
 
### **3.1 Configuration du Serveur DNS (sur Windows)**

**Installation de BIND via Ansible :**
- Créer un playbook Ansible `dns_setup.yml` pour la configuration.
- Créer un fichier `dns_installation.yml` pour l’installation.
- Voir d’autres fichiers dans l’arborescence si on a des rôles communs.
- Suivre la procédure sur AD ci-dessous si sous Windows.

**Post-Installation :**
- Ajouter les enregistrements DNS nécessaires pour les serveurs LDAP, MongoDB et Rocket.Chat dans la configuration de BIND.
- Tester la résolution DNS à partir d'autres serveurs.

### **3.2 Mise en Place de l'Active Directory (AD)**

**Installation de l'Active Directory :**

    - L'installation et la configuration d'AD doivent être effectuées manuellement sur le serveur Windows, car Ansible ne peut pas gérer Windows de la même manière que Linux.
    - On peut installer l’AD ou autre service Windows en suivant la procédure suivante :

    **Configuration de WinRM sur la machine Windows :**
    - Activer winRM : `winrm quickconfig -q`
    - Autoriser les connexions à distance : `Set-Item WSMan:\localhost\Client\TrustedHosts -Value <Adresse_IP_de_votre_machine_Ubuntu>`
    - Configurer le pare-feu : Autoriser le trafic WinRM à travers le pare-feu Windows.

    **Création d’un inventaire Ansible avec les infos de la machine :**
    ```ini
    [windows_servers]
    windows_server ansible_host=192.168.1.100 ansible_user=admin
    ```

### **3.3 Installation et Configuration du Serveur LDAP**

    Installation d’OpenLDAP via Ansible :

        Suivre la procédure donnée pour l’AD (machine sur windows)
        Créer des playbook Ansible ldap_setup.yml et celui d’installation (voir rôle commun)

    Post-Installation :

        Configurer le schéma LDAP pour l'intégration avec Active Directory.
        Tester la connexion LDAP avec ldapsearch pour vérifier l'accès.
     

### **3.4 Installation de MongoDB via Ansible**

    Installation de MongoDB :

        Créer un playbook Ansible mongodb_setup.yml et celui d’installation (voir celui des rôles ou variable commune)
               - Installer MongoDB.
               - Configurer les permissions de sécurité et créer un utilisateur administrateur.
               - S'assurer que le service est démarré et activé au démarrage.

    Post-Installation :

        Créer un utilisateur administrateur pour MongoDB avec des droits appropriés.
        Tester la connexion à MongoDB avec mongo pour s'assurer que le service fonctionne.

 
### **3.5 Installation de Node.js via Ansible**

    Installation de Node.js :

        Crée un  rocketchat_setup.yml et celui d’installation (voir celui des rôles ou variable commune) :

               - Installer Node.js et npm.
               - Vérifier l'installation en affichant les versions installées.

    Post-Installation :

        Mettre à jour npm à la dernière version.
        Vérifier que npm fonctionne correctement en installant un paquet de test.

### **3.6 Installation de Rocket.Chat via Ansible**

    Installation de Rocket.Chat :

        Crée à rocketchat_setup.yml et celui d’installation (voir celui des rôles ou variable commune) :

               - Télécharger la dernière version de Rocket.Chat depuis le dépôt officiel.
               - Extraire l'archive et déplacer les fichiers dans le répertoire approprié.
               - Installer les dépendances nécessaires avec npm.
               - Configurer les variables d'environnement requises pour Rocket.Chat.
               - Démarrer le serveur Rocket.Chat et s'assurer qu'il s'exécute en tant que service.

    Post-Installation :

        Configurer les paramètres de base de données dans le fichier .env, y compris l'URL de MongoDB.
        Créer un service systemd pour que Rocket.Chat s'exécute au démarrage.
         
    Démarrage de Rocket.Chat :

        Créer un service systemd pour Rocket.Chat afin de l'exécuter en tant que service.
         

### **3.7 Intégration de l'Authentification LDAP**

    Configuration de Rocket.Chat pour utiliser LDAP :

        Ajouter la configuration LDAP dans le fichier .env de Rocket.Chat, en utilisant un modèle Jinja2 pour personnaliser la configuration.

 
### **3.8 Tests de l'Intégration LDAP**

    Vérifier la connexion et l'authentification des utilisateurs via LDAP en essayant de se connecter avec des comptes existants.
    Tester le fonctionnement des groupes et des permissions.

 
# **Sécurité**
 

    HTTPS : Configurer un certificat SSL (Let's Encrypt recommandé pour la production).

    SSH sécurisé :

        Désactiver l'accès root.
        Utiliser des clés SSH pour l'authentification.

    Logs : Mettre en place un système de surveillance des logs pour détecter les activités suspectes.
     

# **Tests**
 

    Validation de l'interface : Accéder à Rocket.Chat via l'URL du serveur et vérifier le bon affichage.

    Tests d'authentification :

        Vérifier le fonctionnement des méthodes d'authentification configurées, y compris LDAP, en tentant de se connecter avec des comptes existants.

    Test de communication Rocket.Chat :

        Créer au moins deux comptes utilisateurs dans Rocket.Chat.
        Envoyer des messages entre ces comptes pour vérifier que la communication fonctionne correctement.
        Vérifier la réception des messages dans l'interface de chaque compte.

    Tests de charge : Effectuer des tests de performance sous différentes charges d'utilisateurs pour évaluer la réactivité du système.
     

# **Documentations :** 

    **Procédures :** Documenter toutes les étapes réalisées dans un format clair et structuré.

    - **Contenu à inclure :**
    - Commandes utilisées avec sorties attendues.
    - Configurations spécifiques à DNS, AD, LDAP, MongoDB, Node.js et Rocket.Chat.
    - Captures d'écran des étapes clés pour validation.
    - **Guide utilisateur :** Fournir des instructions claires pour la connexion et l'utilisation de Rocket.Chat.
    - **Maintenance (si il reste du temps)**
    - Prévoir un plan de maintenance régulier pour les mises à jour de sécurité et de fonctionnalité.
    - Mettre en place un système de sauvegarde régulier pour les données de MongoDB et les configurations de Rocket.Chat.
    - Assurer une surveillance proactive du système (utilisation de monitoring comme Prometheus/Grafana).
