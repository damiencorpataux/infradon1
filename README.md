<!-- ![HEIG-VD](https://heig-vd.ch/images/heig-vd-logo.gif)<br> -->
Cours InfraDon 1
=

Le cours **Infrastructures de données** s'articule en 15 sessions de 4 periodes.
- [Détail des sessions](https://github.com/damiencorpataux/infradon1/wiki)
- [Questions & Réponses](https://github.com/damiencorpataux/infradon1/issues) ?

Le support pour la partie pratique est dans ce dépôt git, organisé en 3 répertoires:
- [infra/](infra/) - Infrastructure logicielle (docker)
- [data/](data/) - Jeux de données d'exemple
- [doc/](doc/) - Documentation connexe: Manuels, livres, descriptifs de cours, etc.

---

1: Introduction et infrastructure
-
- Présentation des **SGBD (DBMS) et PostgreSQL**
- Introduction à **Linux**
- Introduction à la **Command Line Interface (CLI)**
- Installation de **Docker**

2: Installation de PostgreSQL (serveurs et clients)
-
- Présentation des **environements de déployement (développement, production, ...)**
- Installation **sur les machines**
- Installation du **container Docker**
- Présentation de l'**architecture client/serveur**
- Présentation et installation des **types de clients (CLI et GUI)** pour se connecter à PostgreSQL

3: Types de données
-
- Les **opérateurs**
- Les **fonctions**

*Proposition: inverser 2 et 3*

4: Structure de données (1)
-
- Présentation de la typologie de stockage: **serveur, bases de données, schémas, tables, colonnes**
- Commandes SQL agissant sur la structure: **CREATE, ALTER, DROP**

5: Manipulation des données et requêtes
-
- Commandes SQL agissant sur les données: **INSERT, UPDATE, DELETE**
- Commandes SQL pour les requêtes: **SELECT, JOIN**
- Jointures externes: **JOIN** (rappel)
  <br>https://www.w3schools.com/sql/sql_join.asp *(nice diagrams)*

*Question: que signifie Rappel ?*

6: Structures de données (2)
-
- Les **vues**
- L'**héritage**

*Proposition: inverser 6 et 7*

7: Optimisation des requêtes
-
- Les **index**
- Les **séquences**

8: Examen 1
-
- Mercredi 17 avril 2024 (3 classes en même temps, avec surveillants)

9: Intégrité des données (1)
-
- Intégrité référentielle et clés étrangères (FKeys)
- Les **contraintes de colonnes**
- Les **contraintes de tables**

10: Intégrité des données (2)
-
- Les **transactions**
- Les **curseurs**

11: Fonctions avancées (1)
-
- Programmation de fonctions (connaissance passive)
- Procédures stockées

12: Fonctions avancées (2)
-
- Les déclencheurs (triggers)
- Type de données tableau

13: Administration
-
- Gestion des droits

14: Sauvegarde et restauration des données
-
- Export SQL
- Import SQL

15: Examen 2
-
- Mardi 11 juin 2024 (3 classes en même temps, avec surveillants)
