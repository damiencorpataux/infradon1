Exemples
=
Quelques exemples de projets minimalistiques:


Contacts
-
Répertoire de contacts qui stocke quel genre de relation on a avec chacun de nos contacts.


Mini Messenger
-
Une structure de données permettant d'envoyer des messages entre contacts.


Good Grade
-
Votre application de gestion de notes avec calcul des moyenne par note, par module et par période académique (semestre) - vous pouvez ajouter des traitements pour faire des projections de moyennes avec les données de notes existantes.

Cette application démontre un use-case minimaliste d'architecture client-serveur multi-tiers (la DB, l'API, le Navigateur, les services internet de base comme DNS ou DHCP, ...).

Installation (CLI):
1. Entrer dans le répertoire de l'application
   <br>`cd examples`
2. Importer la base de données
   <br>`psql -h localhost -U postgres -d postgres -a -f 03-goodgrade-data.sql`
3. Démarrer le Service HTTP
   <br>`./03-goodgrade-api.sh`
4. Accéder à la Web App
   <br>`open http://localhost:8080/` ouvrir cet url dans un navigateur
   <br>`open 03-goodgrade-ui.html` ou alors ouvrir le fichier local avec un navigateur

*Diagramme de composants* de l'architecture de l'application:
- Client-serveur **Postgres** - pour stocker et fournir les données (*psql*)
- Client-serveur **HTTP** et **REST** - JS/HTML: la logique applicative et son UI - JSON: les données de la part de postgres (*netcat*, *navigateur*, *moteur javascript*)
- Client-serveur **DNS**, **DHCP**, etc. - hors scope de notre architecure, ce sont des services omniprésent et fondamentaux car inhérent au fonctionnement d'internet
<br><br>![Good Grade architecture](https://raw.githubusercontent.com/wiki/damiencorpataux/infradon1/img/goodgrade-architecture.drawio.png)

Parcourez le chemin entre le *modèle relationnel* (`03-goodgrade-data.sql`) et le *client HTTP* (le navigateur). Il y'a un *service HTTP*, un *service REST*, une communication *client/serveur Postgres* via `psql`... Mais encore ?

Cette architecture à l'inconvénient de ne pas pouvoir être évolutive. Mais elle a l'avantage de démontrer les interactions entre les composants (Navigateur, API, SGBDR) avec un minimum de couches - c-à-d de manière épurée.

D'un point de vue MVC nous avons:
- **Model:** Le modèle de données `03-goodgrade-data.sql`
- **Controller:** Le service *HTTP* (*Web* & *REST*): la partie *Web* permet de servir l'Application Web avec son UI (c-à-d la page HTML/JS) et *REST* permet d'interroger les données (le lien entre l'UI et les données, c-à-d la partie modèle de données relationnelles)
- **View**: L'application JS/HTML `03-goodgrade-ui.html`, servie par le partie *HTTP* du *Controller*

Sandbox
-
Quelques essais. Que se passe-t-il...
- Si je crée un enregistrement avec 20 caractères dans un champs qui peut en contenir 10 ?
- Si j'essaie de mettre une valeur NULL dans une colonne NOT NULL ?
