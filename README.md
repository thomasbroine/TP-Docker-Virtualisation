<h1 style="font-size: 45px;">TP Virtualisation Docker</h1>

 Dans le cadre de mon cours de virtualisation, j'ai été amené à manipuler Docker donc à créer des conteneurs et un réseau pour y implémenter un projet web déjà existant.  
 Voilà un compte-rendu de mes manipulations.


- [Installation Docker](#installation-docker)
- [Liste de commandes Docker](#liste-de-commandes-docker)
- [Mise en place d'un site web sur Docker](#mise-en-place-dun-site-web-sur-docker)
    - [Création d'un Network](#création-dun-network)
    - [Création du volume](#création-du-volume)
    - [Création du compose](#création-du-compose)
    - [Création du build](#création-du-build)
- [Conclusion](#conclusion)




## Installation Docker
Avec un environnement Windows, il faudra installer un noyau Linux. Pour cela j'ai installé **WSL2** :  
https://learn.microsoft.com/en-us/windows/wsl/install  

Je peux maintenant installer **Docker Desktop** qui permet de gérer Docker en ligne de commandes ou via une interface graphique :  
https://docs.docker.com/desktop/install/windows-install/

## Liste de commandes Docker 
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
    



## Mise en place d'un site web sur Docker 
En complément de consigne, je dois utiliser les notions **compose, network, volume et build**. Et je dois construire un environnement de développement exploitant le serveur postgresql de l’iut avec extension postsig et le serveur web de l’iut avec xdebug.

#### Création d'un Network 
Docker utilise des réseaux pour connecter des conteneurs entre eux et au monde extérieur. Le mode de réseau par défaut de Docker est appelé **bridge** Dans ce mode, chaque conteneur est connecté à un réseau virtuel privé , qui est créé automatiquement lorsque Docker est installé.

Créer un réseau nommé "sae" : 

    docker network create sae

Créer un conteneur connecté au réseau sae :

    docker run -dp 82:80 --network sae --name nginx2 nginx

#### Création du volume 
Afin de rendre persistantes les données entre une machine hôte et un conteneur il est possible de créer un volume permettant de stocker localement certaines données du conteneur

Pour cela on doit créer un fichier "docker" qui sera le volume hôte.
Puis dans le terminal j'écris : 

    docker run -dp 89:80 -v /c/users/.../docker:/var/www/html --name web89  php:8.2-apache

En résumé, cette commande est utilisée pour créer et exécuter un conteneur Docker qui héberge un site web basé sur Apache et PHP, en montant un volume pour persister les données du site web.

#### Création du compose 
Compose est un outil qui permet de gérer et d'orchestrer plusieurs conteneurs Docker de manière coordonnée. Il permet de définir et de lancer des applications multi-conteneurs à l'aide d'un seul fichier de configuration YAML, appelé "docker-compose.yml". Dans mon exercice, il va se charger de relier mes conteneurs au réseau créé, de créer les volumes et autres.  
Ce fichier doit être stocké dans le fichier "docker".  
Voilà comment il doit être construit :  
    
    version: '3.8'

    services:

        web89:
            image: php:8.2-apache
            container_name: web89
            ports:
              - 89:80
            volumes:
              - ./web89/html:/var/www/html
              - ./web89/apache/sites_enabled:/etc/apache2/sites_enabled
              - ./web89/php/custom-php.ini:/use/local/etc/php/conf.d/custom-php.ini
            environment:
              - DATABASE_HOST=db
              - DATABASE_PORT=5432
              - DATABASE_NAME= <name>
              - DATABASE_USER= <user>
              - DATABASE_PASSWORD= <password>
            depends_on:
              - db
            networks:
              - app_network


        db:
            image: postgis/postgis:latest
            environment:
              - POSTGRES_DB= <database>
              - POSTGRES_USER= <user>
              - POSTGRES_PASSWORD= <password>
            ports:
              - "5432:5432"
            volumes:
              - db_data:/var/lib/postgresql/data
            networks:
              - app_network

        networks:
            app_network:
                driver: bridge

        volumes:
            db_data:


#### Création du build
Il est possible d’ajouter une étape supplémentaire dans notre compose dite “build” afin de prendre une image et de la préparer avec des actions personnalisées avant de l’utiliser.  
Pour pouvoir utiliser Xdebug je vais en avoir besoin.  

Je dois donc créer un fichier Dockerfile **(majuscule sur le D et sans extension)** et l'ajouter dans le fichier du projet.
Je peux ensuite écrire à l'intérieur :

    FROM php:8.2-apache

    RUN docker-php-ext-install pdo pdo_pgsql
    RUN pecl install xdebug && docker-php-ext-enable xdebug

    COPY . /var/www/html/

Je dois ensuite ajouter une ligne au début du fichier _docker-compose.yml_ :

    version: '3.8'

    services:

        web89:
            build: .

## Conclusion 
Malgré une complexité d'initialisation et d'utilisation, Docker présente de nombreux avantages tel que la consistance, qui permet d'exécuter des environnement et des application de manière cohérente, ou la portabilité, car
ils peuvent être déployés sur n'importe quel système d'exploitation.  
Ce TP m'a permis de comprendre de nombreux principes de Docker qui me seront utiles très prochainement en entreprise.