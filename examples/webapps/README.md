Exemples
=
Quelques exemples de projets minimalistiques:

<!-- 
Sandbox
-
Quelques essais. Que se passe-t-il...
- Si je crée un enregistrement avec 20 caractères dans un champs qui peut en contenir 10 ?
- Si j'essaie de mettre une valeur NULL dans une colonne NOT NULL ?
 -->

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


### Installation (CLI):

Installation via le shell `bash` ou `zsh` - utilisez votre compte sur `pingouin.heig-vd.ch` si nécessaire:
1. Entrer dans le répertoire de l'application
   <br>`cd examples`
2. Importer la base de données
   <br>`psql -v ON_ERROR_STOP=1 -h localhost -U postgres -a -f 03-goodgrade-model.sql`
3. Démarrer le Service HTTP
   <br>`./03-goodgrade-controller.sh`
4. Accéder à la Web App
   <br>`open http://localhost:8080/` ouvrir cet url dans un navigateur
   <br>`open 03-goodgrade-view.html` ou alors ouvrir le fichier local avec un navigateur
<!-- 
Il est possible de faire tourner le service HTTP en arrière-plan:
<br>`nohup ./02-micromessenger-controller.sh > 02-micromessenger.log 2>&1 &`
 -->

### Diagramme de composants

Voici un schéma des composants du système Applicatif (l'application):
<br><br>![Good Grade architecture](https://raw.githubusercontent.com/wiki/damiencorpataux/infradon1/img/goodgrade-architecture.drawio.png)

Parcourez le chemin entre le *modèle relationnel* (`03-goodgrade-model.sql`) et le *client HTTP* (le navigateur). Il y'a un *service HTTP*, un *service REST*, une communication *client/serveur Postgres* via `psql`... Mais encore ?

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

### Pourquoi faire ?

 A partir de là, on peut démontrer plein de chose en pratique réelle:

- C'est quoi **le protocole HTTP**, démontrer **le cycle** de **1 requête client/serveur**, avec le **navigateur**, **curl** et jusqu'à **telnet** (taper le header a la main)
  ca leur montre les couches d'automatisation entre telnet (ou netcat) et un full-blown navigateur qui fait tout pour toi

- C'est quoi **un serveur HTTP (Web)**, donc on s'**appuye sur la couche HTTP** pour **passer du contenu HTML** que le navigateur va interpréter et afficher de manière graphique, ce qui en fait un GUI.

- C'est quoi **un API (ici REST)**, donc on s'**appuye sur la couche HTTP** pour **passer du contenu JSON**, souvent des données provenant d'une DB - le format JSON est intéressant pour JS qui va consommer ca
  <br>démonstration pratique facile avec ces même outils (*navigateur*, *curl*, *telnet*), et écrire une requête *REST* en *JS*, la boucle est bouclée pour le *Service API/HTTP* qui fait le lien entre *Modèle* et *Vue*

- C'est quoi **une App**, même méthode: **on décompose** les étapes, **on les fait à la main** et on justifie l'utilisation de l'outil high-level - mais maintenant **on est conscient de ce qui se passe** dessous, puisque c'est **notre job**

- C'est quoi **la sécurité**: en termes d'**accès** (là y'en à zero), en terme d'**exploit** eg. *SQL injection* (démontrer comment ca marche: ici pas possible par design, mais il suffit d'*implémenter* dans *Controller* (mon serveur HTTP en bash) un *argument* pour *filtrer les données* et la *clause WHERE* fera une jolie *faille* du *coté SQL* :)

Et on peut imaginer implémenter la même chose avec le Mini Messenger (la db peut gérer la notion de groupe, de read-status, et plein de choses en fait, c'est assez cool aussi)

### Démonstration

C'est parti !

**Prenons le temps d'expérimenter** le dialogue client-serveur en mode "bas-niveau". Car oui, en plus d'interagir avec les données à travers le *GUI* (ici, l'interface Web composée de HTML+JS), *nous pouvons parler directement* avec le *service SGBDR*, ou parler à son intermédiaire le *service HTTP*.

Choses à expérimenter:

- Faire une requête SQL en CLI:
  <br>`psql -h localhost -p 5432 -U postgres -d micromessenger -c "SELECT * FROM view_contacts"`

- Faire une requête HTTP en CLI, avec le client HTTP `curl`:
  <br>`curl -v http://perdu.com/`

- Faire une requête HTTP en CLI, à la main avec un terminal, par exemple `telnet`:
  <br>*Observer que, lorsque nous tappons `perdu.com` dans la barre d'adresse d'un navigateur, il se passe plein de choses que le navigateur fait pour nous (couche d'automatisation) !*

  ```s
  telnet perdu.com 80
  ```
  ```s
  Trying 104.21.5.178...
  Connected to perdu.com.
  Escape character is '^]'.
  GET / HTTP/1.1
  Host: perdu.com

  HTTP/1.1 200 OK
  Date: Thu, 14 Mar 2024 16:31:17 GMT
  Content-Type: text/html
  Transfer-Encoding: chunked
  Connection: keep-alive
  Last-Modified: Thu, 02 Jun 2016 06:01:08 GMT
  ETag: W/"cc-5344555136fe9-gzip"
  Cache-Control: max-age=600
  Expires: Thu, 14 Mar 2024 16:41:16 GMT
  Vary: Accept-Encoding,User-Agent
  CF-Cache-Status: DYNAMIC
  Report-To: {"endpoints":[{"url":"https:\/\/a.nel.cloudflare.com\/report\/v4?s=tjMy1b6zPrvNGNzJfUGrgXJGgEEhWJKSJQtS65syNHHe8HpGILQALO2wZUx7R1BEPQa3Ua%2BJqKwEnBMEO4amxd7HcazgRaLEWRtU2oWBvpvXvuugpLgq9bsvKZ4%3D"}],"group":"cf-nel","max_age":604800}
  NEL: {"success_fraction":0,"report_to":"cf-nel","max_age":604800}
  Server: cloudflare
  CF-RAY: 8645a7259c1e7900-CDG
  alt-svc: h3=":443"; ma=86400


  cc
  <html><head><title>Vous Etes Perdu ?</title></head><body><h1>Perdu sur l'Internet ?</h1><h2>Pas de panique, on va vous aider</h2><strong><pre>    * <----- vous &ecirc;tes ici</pre></strong></body></html>
  ```

- Voir comment le schéma d'un cycle d'une requête illustre ce qui ce passe ci-dessus:
  ![Cycle d'une requête](img/client-server-request-cycle.drawio.png)

- Le service HTTP est un script bash vulnérable.
  <br>Avec un script `bash` (ou `zsh` sous Mac). Provoquez un dénial of service ce service HTTP,
  <br>en utilisant le shell `bash` de `pingouin.heig-vd.ch` si vous n'avez pas de shell `bash` ou `zsh`:
  ```sh
  while true; do
    curl --silent --show-error localhost:8080/api/messages 1>/dev/null;
  done;
  ```
  - Ceci est une boucle for en `bash` ou `zsh`.

- L'implémentation du service HTTP est vulnérable.
  <br>Floodez le système de messages:
  ```sh
  while true; do
    curl --silent --show-error -X POST localhost:8080/api/messages/1/2/Hello 1>/dev/null;
  done;
  ```
  - Nous utilsons le *client HTTP* `curl` pour faire nos requeêtes vers le *service correspondant*.
  - Nous passons l'*argument* `-X POST` à la commande `curl` afin d'envoyer une requête HTTP *POST* vers le *service HTTP*.
  - Nous passons les *arguments* `--silent` et `--show-error` à la commande et ajoutons le suffixe `1>/dev/null` afin de n'afficher que les erreurs - et masquer le contenu des réponses HTTP.

- Faites exactement la même chose en parlant non pas avec le *service HTTP* mais directement avec le *service SGBDR* (c'est malin):
  ```sh
  while true; do
    echo "\n*** Sending message: $url";
    sql="INSERT INTO rel_message (contact_id_source, contact_id_destination, content) VALUES (1, 2, 'Hello')"
    psql -h localhost -p 5432 -U postgres -d micromessenger -c "$sql"
    sleep 3;
  done;
  ```
  - Nous utilisons le *client* `psql` pour nous connecter directement vers le *service SGBDR* (la base de données).
  - Nous mettons l'URL à appeler entre `"` car il contient un espace.

- Comprenez la nécessité des couches de sécurité: *authentification*, *prévention d'attaques*, *cryptage des données transférées*, et surtout: mettre un *Front-end* (ici le *service HTTP*) qui fait front entre l'utilisateur et la base de données (le *service SGBDR*). C'est le *Front-end* qui assure une partie de la sécurité.

- Créez un "bot" qui donne l'heure toutes les 3 secondes (c'est malin):
  ```sh
  while true; do
    url=$(echo "localhost:8080/api/messages/1/2/Salut on est le $(date)");
    url_encoded=$(echo $url | sed 's/ /%20/g');
    echo "\n*** Sending message: $url";
    curl -vv -XPOST "$url_encoded";
    sleep 3;
  done;
  ```
  - Le *protocole* HTTP nous demande d'*encoder* l'*URL*, notamment remplacer les espaces ` ` par `%20` - mais pas que: https://en.wikipedia.org/wiki/Percent-encoding
  - Notez que dans `"Nous somme le $(date)` le `$()` a pour effet d'exécuter la commande bash `date` et de remplacer le tout par le retour de cette commande `date`.

- Faites exactement la même chose en parlant non pas avec le *service HTTP* mais directement avec le *service SGBDR* (c'est malin):
  ```sh
  while true; do
    echo "\n*** Sending message: $url";
    sql="INSERT INTO rel_message (contact_id_source, contact_id_destination, content) VALUES (1, 2, '$(date)')"
    psql -h localhost -p 5432 -U postgres -d micromessenger -c "$sql"
    sleep 3;
  done;
  ```
  - Notez que le service HTTP n'a pas besoin de tourner pour effectuer cette opération. C'est tout naturel: nous parlons directement avec la DB, c-à-d le *service SGBDR*, via `psql`.

- Comprenez que l'*implémentation du service HTTP* (le script bash) n'est pas viable en *production*. Elle a l'avantage d'être ultra-simple dans un but pédagogique. Mais elle est aussi très efficace, mesurez le temps que met une réponse avec beaucoup de données (après le flood de messages):
  - `time curl -i localhost:8080/api/messages` - pour 1 requête (faible charge)
  - `while true; do time curl --silent --show-error localhost:8080/api/messages 1>/dev/null; done` - pour n requêtes (grosse charge), notez que le service HTTP n'arrive pas à répondre à toutes les requêtes !

- Essayez de faire une injection SQL...
  <br>https://www.w3schools.com/sql/sql_injection.asp

- Et pendant qu'on y est, qu'est-ce que ca fait si je me connecte au port `5432` de mon `localhost` avec telnet ?
  - `telnet localhost 5432`
  - Parlez-vous le protocole du *service Postgres* ?
