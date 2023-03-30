# TP Docker Virtualisation
 Dans le cadre de mon cours de vitualisation, j'ai été amené à manipuler Docker donc à créer des conteneurs et un réseau pour y implémenter un projet web déjà existant.  
 Voilà un compte rendu de mes manipulations.


- [Installation Docker](#installation-docker)
- [Commandes Docker](#section-1)
- [Site Web sur Docker](#mise-en-place-dun-site-web-sur-docker)  






# Installation Docker
Avec un environnement Windows, il faudra installer un noyau Linux. Pour cela j'ai installer WSL2 :  
https://learn.microsoft.com/en-us/windows/wsl/install  

Nous pouvons maintenant installer Docker Desktop qui permet de gérer Docker en ligne de commandes ou via une interface graphique :  
https://docs.docker.com/desktop/install/windows-install/

# Liste des commandes Docker que nous allons utiliser : {#section-1}
Toutes les commandes sont à lancer dans un terminal quelconque.
* Pour afficher tous les conteneurs Docker en cours d'exécution : 

        docker ps
* Pour afficher l'utilisation de l'espace disque par Docker :

        docker system df -v

* Pour créer un conteneur :

        docker run -dp "portExposé":"portInterne" "Image"  

* Pour lancer un conteneur :

        docker start id ## ou nom ## ou début de l’id non ambigu

* Pour arreter un conteneur :

        docker stop id ## ou nom ## ou début de l’id non ambigu

* Pour supprimer un conteneur :
  
        docker rm id ## ou nom ## ou début de l’id non ambigu
    



# Mise en place d'un site web sur Docker 
En complément de consigne, nous devons utiliser les notions compose, network, volume et build. Et nous devons construire un environnement de développement exploitant le serveur postgresql de l’iut avec extension postsig et le serveur web de l’iut avec xdebug.

### Création d'un Network : {#section-3}
Docker utilise des réseaux pour connecter des conteneurs entre eux et au monde extérieur. Le mode de réseau par défaut de Docker est appelé **bridge** Dans ce mode, chaque conteneur est connecté à un réseau virtuel privé , qui est créé automatiquement lorsque Docker est installé.

Créer un réseau nommé "sae" : 

    docker network create sae

Créer un conteneur connecté au réseau sae :

    docker run -dp 82:80 --network sae  nginx

### Création du volume : {#section-4}
Afin de rendre persistantes les données entre une machine hôte et un conteneur il est possible de créer un volume permettant de stocker localement certaines données du conteneur

Pour cela on doit créer un fichier "docker" qui sera le volume hôte.
Puis dans le terminal on écrit : 

    docker run -dp 89:80 -v /c/users/.../docker:/var/www/html --name web89  php:8.2-apache

En résumé, cette commande est utilisée pour créer et exécuter un conteneur Docker qui héberge un site web basé sur Apache et PHP, en montant un volume pour persister les données du site web.

### Notion de compose : {#section-5}
Compose est un outil qui permet de gérer et d'orchestrer plusieurs conteneurs Docker de manière coordonnée. Il permet de définir et de lancer des applications multi-conteneurs à l'aide d'un seul fichier de configuration YAML, appelé "docker-compose.yml".