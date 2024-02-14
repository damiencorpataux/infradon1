Infrastructure
=

Le rôle d'une *infrastructure* est de mettre à disposition un ou plusieurs *services*. Ici, une *base de donnée relationnelle* disponible sur le port 5432 (et 5433 pour l'*environnement de développement*).

Le service est ensuite consommé par un ou plusieurs *clients*, par exemple une *application web*, ou un *client CLI* comme `psql`.


Serveur `pingouin` (production)
-
Ce serveur est désactivé momentanément. Nous utiliserons un *serveur de production* sous forme de *container Docker* que nous pouvons migrer par la suite sur `pingouin.heig-vd.ch`.

Serveur Docker (production)
-
PostgreSQL sous forme de container Docker. Il permet de monter rapidement sur votre machine un serveur PostgreSQL identique à un *environnement de production*.

1. Installer Docker: https://docs.docker.com/get-docker/

2. Lancer le serveur PostgreSQL containerisé:
   ```sh
   cd infra/docker
   docker compose up
   ```
   [![asciicast](https://asciinema.org/a/i6yDNrf01nTOXZH9Gk3aJ6RVF.svg)](https://asciinema.org/a/i6yDNrf01nTOXZH9Gk3aJ6RVF)

3. Utiliser le serveur...

4. Shutdown le serveur: appuyer sur les touches `ctrl`+`c`.

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