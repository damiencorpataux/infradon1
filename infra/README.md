Infrastructure
=

Le rôle d'une *infrastructure* est de mettre à disposition un ou plusieurs *services*. Ici, une *base de donnée relationnelle* disponible sur le port 5432 (et 5433 pour l'*environnement de développement*).

Le service est ensuite consommé par un ou plusieurs *clients*, par exemple une *application web*, ou un *client CLI* comme `psql`.

Dans notre use case, nous créons une *infrastructure* fournissant un *service de gestion de données relationnelles (SGBD)*. Ce service est assuré par un serveur PostgreSQL. 2 environnements...

Serveur `pingouin` (production)
-
Ce serveur est désactivé momentanément. Nous utiliserons un *serveur de production* sous forme de *container Docker* que nous pouvons migrer par la suite sur `pingouin.heig-vd.ch`.

Serveur Docker (production)
-
PostgreSQL sous forme de container Docker. Il permet de monter rapidement sur votre machine un serveur PostgreSQL identique à un *environnement de production*.

1. Installer Docker: https://docs.docker.com/get-docker/

1. Télécharger le fichier `compose.yaml` et le placer dans le *répertoire de travail* de votre choix pour ce projet
   https://github.com/damiencorpataux/infradon1/blob/main/infra/docker/compose.yml

1. Lancer le container Docker tournant le serveur PostgreSQL:
   ```sh
   docker compose up
   ```
   [![asciicast](https://asciinema.org/a/i6yDNrf01nTOXZH9Gk3aJ6RVF.svg)](https://asciinema.org/a/i6yDNrf01nTOXZH9Gk3aJ6RVF)

1. Utiliser le serveur...

1. Shutdown le serveur: appuyer sur les touches `ctrl`+`c`.

Configuration:
- Port: `5432` (port postgres standard)


Serveur Local (développement)
-
PostgreSQL sous forme de serveur installé en local sur votre machine. Il sert d'*evironnement de développement*.

1. Installer PostgreSQL en local: https://www.postgresql.org/download/

Configuration:
- Port: `5433` (port non-standard)


Client PostgreSQL
-
Utilisé pour se connecter au serveurs de développement et de production, le client PostgreSQL permet d'interagir avec la base de données pour toutes les manipulation de maintenance, de tests et d'apprentissage.

1. Les clients CLI et GUI sont installés avec l'installation du [Serveur Local](#serveur-local-développement)

Configuration du client GUI:
- Créer une connexion vers le serveur de développement, quel host et port ?
- Créer une connexion vers le serveur de production, quel host et port ?

Exemple d'utilisation de `psql`:
<br>[![asciicast](https://asciinema.org/a/v1RtQbVwJkiGylTLUhpGnFBkf.svg)](https://asciinema.org/a/v1RtQbVwJkiGylTLUhpGnFBkf)


Lancer un CLI Linux
-
Vous pouvez avoir un CLI Linux (bash) en exécutant cette commande dans votre *répertoire de travail*:
```sh
docker compose exec postgres bash
```
Ceci ouvre une invite de commande en ligne (un CLI) dans votre machine Linux containerisée par Docker.

Si vous recevez le message d'erreur:
```
service "postgres" is not running
```
Vous d'abord devez lancer le container postgres en exécutant cette commande dans votre *répertoire de travail*:
```sh
docker compose up -d
```

<br>[![asciicast](https://asciinema.org/a/Rir5OQ6SfiTiSb2MYSJr2rSl8.svg)](https://asciinema.org/a/Rir5OQ6SfiTiSb2MYSJr2rSl8)


Population du jeu de données d'exemple
-
Il s'agit d'importer le jeu de données fourni dans le répertoire [/data](/data).

1. Télécharger et dézipper le fichier `dvdrental.zip` depuis le répertoire data de ce dépôt github [/data](/data)
   <br>Il s'agit d'un *export* PostgreSQL.

1. Importer les données dans l'*environnement de développement (docker)* en suivant le tutoriel CLI sur https://www.postgresqltutorial.com/postgresql-getting-started/load-postgresql-sample-database/

1. Expérimenter des requêtes SQL de bases, tips: https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-select/

1. Importer les données dans l'*environnement de production* - quel paramètre change par rapport à l'import dans l'*environnement de développement* ?

[![asciicast](https://asciinema.org/a/EVZs5veCbKuXhTlbAKkONR0EA.svg)](https://asciinema.org/a/EVZs5veCbKuXhTlbAKkONR0EA)
