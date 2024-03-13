Exemples
=
Quelques exemples de projets minimalistiques:


Contacts
-
Répertoire de contacts qui stocke quel genre de relation on a avec chacun de nos contacts.


µMessenger
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
   <br>`psql -v ON_ERROR_STOP=1 -h localhost -U postgres -a -f 03-goodgrade-model.sql`
3. Démarrer le Service HTTP
   <br>`./03-goodgrade-controller.sh`
4. Accéder à la Web App
   <br>`open http://localhost:8080/` ouvrir cet url dans un navigateur
   <br>`open 03-goodgrade-view.html` ou alors ouvrir le fichier local avec un navigateur

**Diagramme de composants** de l'architecture de l'application (ici, nous sommes aux niveau de détail *conceptuel* et *implémentation* mélangés pour avoir une vue globale de ce qui est *important point de vue applicatif* - j'ai donc fait des choix de détail pour chaque élément):
- Client-serveur **Postgres** - pour stocker et fournir les données (*psql*)
- Client-serveur **HTTP** et **REST** - fournit le JS/HTML au navigateur: la logique applicative et son UI, et fournit les données au format JSON de la part de postgres jusqu'au navigateur (via *netcat*)
- Client-serveur **DNS**, **DHCP**, etc. - hors scope de notre architecure, ce sont des services omniprésent et fondamentaux car inhérent au fonctionnement d'internet
- Application: Eh bien c'est l'ensemble des 3 éléments ci-dessus, mis enseble...
<br><br>![Good Grade architecture](https://raw.githubusercontent.com/wiki/damiencorpataux/infradon1/img/goodgrade-architecture.drawio.png)

Parcourez le chemin entre le *modèle relationnel* (`03-goodgrade-model.sql`) et le *client HTTP* (le navigateur). Il y'a un *service HTTP*, un *service REST*, une communication *client/serveur Postgres* via `psql`... Mais encore ?

Cette architecture à l'inconvénient de ne pas pouvoir être évolutive. Mais elle a l'avantage de démontrer les interactions entre les composants (Navigateur, API, SGBDR) avec un minimum de couches - c-à-d de manière épurée.

D'un point de vue **MVC** nous avons (ici, quel *niveau de description*?):
- **Model:** Le *modèle de données* et son *service*
  <br>le modèle de données est décrit dans `03-goodgrade-model.sql`
- **Controller:** Le service *HTTP* (*Web* & *REST*) ``: la partie *Web* permet de servir l'Application Web avec son UI (c-à-d la page HTML/JS) et *REST* permet d'interroger les données (le lien entre l'UI et les données, c-à-d la partie modèle de données relationnelles)
  <br>`03-goodgrade-controller.sh`
- **View**: L'application JS/HTML, qui est servie par le partie *HTTP* du *Controller*
  <br>`03-goodgrade-view.html`

Notez bien: Dans cette **Webapp MVC épurée**, implémentée avec tellement "aucune couche", on peut voir son **système nerveux fondamental**. Voici son anatomie (et ici, quel *niveau de description*):
- **Modèle**: C'est notre bon vieux Postgres, notre Service SGBDR - qui nous sert des données
- **Vue**: C'est notre *UI*, une page *JS/HTML* toute simple sans dépendances - qui interagit avec l'utilisateur
- **Controller**: C'est un *script bash* qui utilise *netcat* et *psql* (!) pour fournir un *Service HTTP* - il lie le tout en fournissant l'*App* (la page *JS/HTML*) et les données (au format *JSON*)
https://github.com/damiencorpataux/infradon1/tree/main/examples#good-grade

Et on a l'implémentation minimasite! **1 fichier par élément MVC**, qui se materialise en *Service* (souvent sur un *serveur*, et donc ici *quel niveau de description*?):
- **Modèle**: Service SBGDR:
  fichier `03-goodgrade-model.sql` - nécessite Postgres (outil)
- **Controller**: Service HTTP (Static et REST)
  fichier `03-goodgrade-controller.sh` - nécessite bash (via linux, cygwin, docker: outils)
- **Vue**: Application Web:
  fichier `03-goodgrade-view.html` - nécessite Navigateur (outil)
https://github.com/damiencorpataux/infradon1/tree/main/examples
C'est parti !

A partir de là, on peut démontrer plein de chose en pratique réelle:

- C'est quoi **le protocole HTTP**, démontrer **le cycle** de **1 requête client/serveur**, avec le **navigateur**, **curl** et jusqu'à **telnet** (taper le header a la main)
  ca leur montre les couches d'automatisation entre telnet (ou netcat) et un full-blown navigateur qui fait tout pour toi

- C'est quoi **un serveur HTTP (Web)**, donc on s'**appuye sur la couche HTTP** pour **passer du contenu HTML** que le navigateur va interpréter et afficher de manière graphique, ce qui en fait un GUI.

- C'est quoi **un API (ici REST)**, donc on s'**appuye sur la couche HTTP** pour **passer du contenu JSON**, souvent des données provenant d'une DB - le format JSON est intéressant pour JS qui va consommer ca
  <br>démonstration pratique facile avec ces même outils (*navigateur*, *curl*, *telnet*), et écrire une requête *REST* en *JS*, la boucle est bouclée pour le *Service API/HTTP* qui fait le lien entre *Modèle* et *Vue*

- C'est quoi **une App**, même méthode: **on décompose** les étapes, **on les fait à la main** et on justifie l'utilisation de l'outil high-level - mais maintenant **on est conscient de ce qui se passe** dessous, puisque c'est **notre job**

- C'est quoi **la sécurité**: en termes d'**accès** (là y'en à zero), en terme d'**exploit** eg. *SQL injection* (démontrer comment ca marche: ici pas possible par design, mais il suffit d'*implémenter* dans *Controller* (mon serveur HTTP en bash) un *argument* pour *filtrer les données* et la *clause WHERE* fera une jolie *faille* du *coté SQL* :)

- etc, etc...: J'ai fait une vidéo (pour moi, elle est en unlisted) de ce que j'ai a leur montrer la dessus (je peux la regarder 20 minutes dans le train et me charger neurones pour le cours)
https://www.youtube.com/watch?v=ZyhKqrJV-Vk

Et on peut imaginer implémenter la même chose avec le Mini Messenger (la db peut gérer la notion de groupe, de read-status, et plein de choses en fait, c'est assez cool aussi)

**En préparation à l'examen**, vous devez pouvoir définir chacun des termes en *italique.


Sandbox
-
Quelques essais. Que se passe-t-il...
- Si je crée un enregistrement avec 20 caractères dans un champs qui peut en contenir 10 ?
- Si j'essaie de mettre une valeur NULL dans une colonne NOT NULL ?
