Infrastructure
=

Le rôle d'une *infrastructure* est de mettre à disposition un ou plusieurs *services*. Ici, une *base de donnée relationnelle* disponible sur le port 5432 pour l'*environnement de développement* (et 5433 pour l'*environnement de production*).

Le service est ensuite consommé par un ou plusieurs *clients*, par exemple une *application web*, ou un *client CLI* comme `psql`.

Dans notre use case, nous créons une *infrastructure* fournissant un *service de gestion de données relationnelles (SGBDR)*. Ce service est assuré par un serveur PostgreSQL. 2 environnements...

Serveur `pingouin` (production)
-
Ce serveur est désactivé momentanément. Nous utiliserons un *serveur de production* sous forme de *container Docker* que nous pouvons migrer par la suite sur `pingouin.heig-vd.ch`.

En attendant, nous avons recours à un serveur de teste non backupé ni sécurisé. N'y placez aucune donnée sensible:
- `134.209.192.104`


Installation du Serveur PostgreSQL (en local)
-
PostgreSQL sous forme de serveur installé en local sur votre machine. Il sert d'*environnement de développement*.

1. Installer PostgreSQL en local: https://www.postgresql.org/download/

Configuration:
- Port: `5432` (port postgres standard)

<!--
Installation du Serveur PostgreSQL (container Docker)
-
PostgreSQL sous forme de container Docker. Il permet de monter rapidement sur votre machine un serveur PostgreSQL identique à un *environnement de production*.

1. Installer Docker: https://docs.docker.com/get-docker/
   <br>**Sous Windows, nous devons parfois:**
   - Il faut activer une option de virtualisation dans le BIOS - video en hindglish, mais très efficace et les CC la traduisent bien: https://www.youtube.com/watch?v=Vj35f6L9TCA
   -Autres solutions remontées par les utilisateurs dans ce thread, je suppose qu'il faudra essayer les plus simples/rapides évidents en premier lieu... j'ai de la pein à dire à priori: https://forums.docker.com/t/an-unexpected-error-was-encountered-while-executing-a-wsl-command/137525/16
2. Télécharger le fichier `compose.yaml` et le placer dans le *répertoire de travail* de votre choix pour ce projet
   (par exemple `postgres-docker`):
   https://github.com/damiencorpataux/infradon1/blob/main/infra/docker/compose.yml
3. Ouvrez un terminal:
   - Sous Windows: Lancer "PowerShell"
   - Sous MacOS: Lancer "Terminal"
4. Entrez dans votre *répertoire de travail*, par exemple:
   ```sh
   cd docker-composer
   ```
5. Lancer le container Docker tournant le serveur PostgreSQL:
   ```sh
   docker compose up
   ```
   [![asciicast](https://asciinema.org/a/i6yDNrf01nTOXZH9Gk3aJ6RVF.svg)](https://asciinema.org/a/i6yDNrf01nTOXZH9Gk3aJ6RVF)
6. Utiliser le serveur: nous pouvons nous connecter avec un client PostgreSQL, par exemple: `sql` (CLI) ou `pgAdmin4` (GUI)
7. Shutdown le serveur: appuyer sur les touches `ctrl`+`c`.

Configuration:
- Port: `5433` (port postgres non-standard)
-->


Lancer un CLI Linux
-
Vous avez plusieurs moyens d'entrer dans un CLI Linux (bash):

- Via SSH (SecureShell), un *serveur de terminal* permettant de se connecter à distance à une machine Linux:
  ```
  ssh student@134.209.192.104
  ```
  Note: `134.209.192.104` est l'IP d'un serveur de tests mis en place pour vos expérimentations.
  [![asciicast](https://asciinema.org/a/9ETlED4CMHsxa6R9s3mfVyg2B.svg)](https://asciinema.org/a/9ETlED4CMHsxa6R9s3mfVyg2B)
<!--
- Via un container Linux tournant sous Docker, en exécutant cette commande dans un terminal, après être entré dans votre *répertoire de travail*:
  ```sh
  cd docker-compose
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
- Via une machine virtuelle Linux tournant sous VMWare ou VirtualBox, par exemple. Nous ne voyons pas ce sujet dans ce cours.
-->


Clients PostgreSQL
-
Utilisé pour se connecter aux serveurs PostgreSQL, le client PostgreSQL permet d'interagir avec la base de données pour toutes les manipulation de maintenance, de tests et d'apprentissage.

1. Les clients CLI et GUI sont installés avec l'installation du [Serveur PostgreSQL](#installation-du-serveur-postgresql-en-local)

Configuration du client GUI:
- Créer une connexion vers le serveur de développement, quel host et port ?
- Créer une connexion vers le serveur de production, quel host et port ?

Utiliser `psql` pour se connecter à une base de données:
- Lancez un terminal
- Tapez `psql --help` pour une aide à propos de la commande
- `psql -h <hostname> -p <port> -U <username> <database>`: se connecter à la base de données nommée `postgres` serveur PostgreSQL écoutant sur le port `5432` de la machine `localhost` avec l'utilisateur `postgres`. Une connection réussi vous affiche l'invite de commande psql:
  ```
  psql (16.2)
  Type "help" for help.

  postgres=# 
  ```
  Remplacez:
  - `<hostname>` par l'IP ou *le nom d'hôte* du serveur PostgreSQL auquel vous voulez vous connecter. Par exemple: `localhost` ou `134.209.192.104` (le serveur de tests)
  - `<port>` par le port sur lequel vous voulez vous connecter (rappel port +ip = socket)
  - `<username>` par le nom d'utilisateur avec lequel vous souhaitez vous connecter
  - `<database>` par le nom de la base de données à laquelle vous voulez vous connecter
  - Le mot de passe vous est demandé ensuite, il est normal que vous ne voyiez rien quand vous tapez.

Utiliser l'invite `psql`:
- `help`: afficher l'aide générale
- `\?`: affiche les commandes propres au moteur postgres
- `\h`: affiche les commandes SQL disponibles

Exemple d'utilisation de `psql`:
<br>[![asciicast](https://asciinema.org/a/v1RtQbVwJkiGylTLUhpGnFBkf.svg)](https://asciinema.org/a/v1RtQbVwJkiGylTLUhpGnFBkf)


Population du jeu de données d'exemple
-
Il s'agit d'importer le jeu de données fourni dans le répertoire [/data](/data).

1. Télécharger et dézipper le fichier `dvdrental.zip` depuis le répertoire data de ce dépôt github [/data](/data)
   <br>Il s'agit d'un *export* PostgreSQL.

2. Importer les données dans l'*environnement de développement (docker)* en suivant le tutoriel CLI sur https://www.postgresqltutorial.com/postgresql-getting-started/load-postgresql-sample-database/

3. Expérimenter des requêtes SQL de bases, tips: https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-select/

4. Importer les données dans l'*environnement de production* - quel paramètre change par rapport à l'import dans l'*environnement de développement* ?

[![asciicast](https://asciinema.org/a/EVZs5veCbKuXhTlbAKkONR0EA.svg)](https://asciinema.org/a/EVZs5veCbKuXhTlbAKkONR0EA)

<!-- 
Notre infrastructure système
-
Après avoir suivi les étapes ci-dessus pour la mise en place de PostgreSQL dans 2 environnements, nous avons l'architecture suivante pour notre infrastructure de données:

![Notre architecture système](../../infradon1.wiki/img/notre-achitecture-systeme.drawio.png)
-->
