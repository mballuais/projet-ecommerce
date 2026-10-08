# EFREI — Analyse d'une plateforme e-commerce

Projet de groupe en SQL, avec PostgreSQL. Cette branche contient la
**partie 7 — Analyse libre**, réalisée par **Galyst**.

## Fichiers

- `create_schema.sql` : création des quatre tables et de leurs relations.
- `seed_ecommerce.sql` : données fournies pour le projet, inchangées.
- `analysis.sql` : trois analyses complémentaires de la partie 7.
- `.gitignore` : exclusion des fichiers macOS et des fichiers temporaires Word.

## Exécution

Prérequis : PostgreSQL démarré, avec les outils `createdb` et `psql` disponibles.
Remplacer `votre_utilisateur` par votre rôle PostgreSQL et exécuter les commandes
depuis la racine du dépôt. Ajouter `-h` et `-p` si le serveur n'est pas local.

Sur une **nouvelle base dédiée au projet** :

```bash
createdb -U votre_utilisateur ecommerce_db
psql -X -U votre_utilisateur -d ecommerce_db -v ON_ERROR_STOP=1 -f create_schema.sql
psql -X -U votre_utilisateur -d ecommerce_db -v ON_ERROR_STOP=1 -f seed_ecommerce.sql
```

Le schéma existant supprime les tables avant de les créer. Il crée également des
séquences indépendantes qui ne sont pas supprimées lors d'une seconde exécution :
utiliser une base neuve pour l'installation. Si les tables et les données sont
déjà chargées, exécuter uniquement les analyses :

```bash
psql -X -U votre_utilisateur -d ecommerce_db -v ON_ERROR_STOP=1 -f analysis.sql
```

Les trois requêtes sont indépendantes, en lecture seule, et peuvent être
réexécutées. Pour conserver leurs résultats dans un fichier texte :

```bash
psql -X -U votre_utilisateur -d ecommerce_db -v ON_ERROR_STOP=1 -P pager=off -f analysis.sql -o resultats_partie7.txt
```

Contrôle du chargement :

```sql
SELECT 'client' AS table_name, COUNT(*) AS nombre_lignes FROM client
UNION ALL SELECT 'produit', COUNT(*) FROM produit
UNION ALL SELECT 'commande', COUNT(*) FROM commande
UNION ALL SELECT 'ligne_commande', COUNT(*) FROM ligne_commande;
```

Résultats attendus : **100 clients, 65 produits, 500 commandes et 1 547 lignes**.

## Méthode commune

Les résultats ci-dessous proviennent de l'exécution de `analysis.sql` sur le
jeu fourni. Les commandes couvrent le **1er janvier au 29 décembre 2025**.
Les **16 commandes annulées** sont exclues des achats, des quantités vendues
et du chiffre d'affaires : le périmètre commercial contient **484 commandes**
pour **617 494,76 €**.

Les montants utilisent toujours `quantite * prix_unitaire`, le prix réellement
payé, et non le prix actuel du catalogue. Les calculs conservent leur précision
avant l'arrondi d'affichage. Une valeur SQL `NULL` signifie qu'un indicateur ne
peut pas être calculé : aucun intervalle entre achats, aucun chiffre d'affaires
au dénominateur ou aucune vente pour estimer une couverture de stock.

Les commandes antérieures à l'inscription d'un client restent dans le périmètre,
conformément à la règle de calcul du sujet. Ces incohérences, étudiées en
partie 5, limitent l'interprétation des comportements clients.

## 7.1 — Fréquence et délai entre achats

**Question.** Quelle place occupent les clients qui achètent plusieurs fois,
et à quel rythme reviennent-ils ?

**Données nécessaires.** Identifiants des clients, identifiants et dates des
commandes, statuts, quantités et prix unitaires des lignes.

**Analyse.** Calculer d'abord le montant de chaque commande non annulée, puis
le nombre d'achats et le chiffre d'affaires par client. Conserver tous les
clients avec une jointure externe et les classer en quatre segments. `LAG`
permet de calculer le délai entre deux commandes successives d'un même client.
La moyenne porte sur tous les intervalles du segment ; deux achats le même
jour donnent un délai de zéro jour.

| Segment | Clients | Part des clients | Commandes | CA (€) | Part du CA | Délai moyen (jours) |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Aucun achat non annulé | 10 | 10,00 % | 0 | 0,00 | 0,00 % | — |
| 1 achat | 2 | 2,00 % | 2 | 1 601,77 | 0,26 % | — |
| 2 à 4 achats | 34 | 34,00 % | 112 | 140 205,14 | 22,71 % | 75,26 |
| 5 achats ou plus | 54 | 54,00 % | 370 | 475 687,85 | 77,04 % | 45,85 |

**Observation.** Les 54 clients ayant au moins cinq achats représentent
77,04 % du chiffre d'affaires. Leur délai moyen entre achats est inférieur à
celui des clients ayant deux à quatre achats. Les pourcentages de CA totalisent
100,01 % uniquement à cause des arrondis.

**Intérêt métier.** Cette segmentation aide à cibler une action de fidélisation
pour les clients fréquents et une relance pour les clients ayant peu acheté.
Le délai observé peut servir de point de départ pour choisir le moment d'une
relance. Il décrit les achats dans la période disponible ; ce n'est pas un taux
de rétention, et les clients récemment arrivés ont eu moins de temps pour acheter.

## 7.2 — Associations de produits dans les commandes

**Question.** Quels produits apparaissent ensemble plus souvent que ce que
leurs fréquences individuelles laisseraient attendre ?

**Données nécessaires.** Identifiants et statuts des commandes, produits des
lignes, identifiants et noms des produits.

**Analyse.** Dédupliquer les produits de chaque commande, puis former des
paires non ordonnées (`produit_a_id < produit_b_id`). Une commande contenant
plusieurs unités ou plusieurs lignes du même produit ne compte qu'une fois.
Retenir les paires présentes dans au moins **5 commandes**, seuil exploratoire
qui limite les associations les plus rares, et présenter les **10 premiers
lifts**. Les égalités sont départagées par le nombre de commandes communes,
puis par les identifiants des produits.

- **Support** : part des 484 commandes contenant les deux produits.
- **Confiance A → B** : part des commandes contenant A qui contiennent aussi B.
- **Confiance B → A** : même calcul dans l'autre sens.
- **Lift** : fréquence commune divisée par le produit des fréquences
  individuelles. Un lift de 1 correspond à l'indépendance ; au-dessus de 1,
  la paire est surreprésentée dans l'échantillon.

| Produit A | Produit B | Commandes communes | Support | Confiance A → B | Confiance B → A | Lift |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| Hub USB 2 | Veste 2 | 6 | 1,24 % | 21,43 % | 26,09 % | 4,51 |
| SSD 1 | Barre de son 2 | 5 | 1,03 % | 17,24 % | 21,74 % | 3,63 |
| Casque 2 | Bouilloire 1 | 6 | 1,24 % | 22,22 % | 20,00 % | 3,59 |
| Bouilloire 1 | Jean 1 | 6 | 1,24 % | 20,00 % | 22,22 % | 3,59 |
| Écran 1 | Hub USB 1 | 5 | 1,03 % | 18,52 % | 20,00 % | 3,59 |
| Montre sport 2 | Jean 1 | 5 | 1,03 % | 19,23 % | 18,52 % | 3,45 |
| Casque 2 | Jean 1 | 5 | 1,03 % | 18,52 % | 18,52 % | 3,32 |
| Souris 1 | Écran 1 | 5 | 1,03 % | 17,86 % | 18,52 % | 3,20 |
| Montre sport 1 | Jean 1 | 6 | 1,24 % | 17,14 % | 22,22 % | 3,07 |
| Casque 1 | Hub USB 1 | 5 | 1,03 % | 15,63 % | 20,00 % | 3,03 |

**Observation.** Hub USB 2 apparaît dans 28 commandes, Veste 2 dans 23, et les
deux ensemble dans 6. Le lift vaut `(6 × 484) / (28 × 23) = 4,51`. Toutefois,
le support reste faible : seulement 1,24 % des commandes.

**Intérêt métier.** Ces associations donnent des pistes de recommandations
complémentaires ou de lots à tester. Les paires Écran 1 / Hub USB 1 et
Souris 1 / Écran 1 ont également une cohérence d'usage. La première paire du
classement associe deux univers différents : un lift élevé sur seulement
cinq ou six commandes ne démontre ni causalité ni complémentarité réelle.
Valider ces pistes sur davantage de données avant une décision commerciale.

## 7.3 — Couverture indicative du stock

**Question.** Quels produits faut-il examiner en priorité si le rythme de
vente des 90 derniers jours se maintient ?

**Données nécessaires.** Stock actuel des produits, dates et statuts des
commandes, produits et quantités des lignes.

**Analyse.** Ancrer la fenêtre sur la dernière date de commande du jeu,
y compris si cette commande est annulée. La période va du **1er octobre au
29 décembre 2025**, soit **90 jours calendaires, bornes incluses**. Compter
uniquement les quantités des commandes non annulées dans cette fenêtre.
Conserver les 65 produits, même sans vente récente.

`Couverture (jours) = stock × 90 / quantité vendue sur 90 jours`.

Classer en premier les stocks nuls avec ventes récentes, puis les couvertures
strictement inférieures à **30 jours**, seuil de suivi choisi pour l'analyse.
Une couverture égale à 30 jours appartient à la catégorie suivante. Sans
vente récente, la couverture reste `NULL` plutôt que d'indiquer une durée fictive.

Extrait des premières lignes, dans l'ordre de la requête :

| Produit | Stock | Quantité vendue sur 90 jours | Couverture (jours) | Situation |
| --- | ---: | ---: | ---: | --- |
| Lampe 2 | 0 | 16 | 0,00 | Stock nul avec ventes récentes |
| Souris 2 | 0 | 10 | 0,00 | Stock nul avec ventes récentes |
| Sweat 1 | 0 | 9 | 0,00 | Stock nul avec ventes récentes |
| Haltères 1 | 1 | 6 | 15,00 | Couverture inférieure à 30 jours |
| Enceinte 1 | 7 | 25 | 25,20 | Couverture inférieure à 30 jours |
| Tapis de yoga 1 | 8 | 24 | 30,00 | Couverture de 30 jours ou plus |

**Observation.** Trois produits ont un stock nul malgré des ventes récentes.
Deux autres présentent une couverture inférieure à 30 jours. Cinq produits
n'ont aucune vente dans la fenêtre ; leur couverture ne peut pas être estimée.

**Intérêt métier.** Le classement aide à prioriser une vérification des stocks
et des besoins de réapprovisionnement. Il complète le simple classement des
ventes en comparant la demande récente au stock disponible.

**Limites.** Le fichier ne donne ni date de relevé du stock, ni historique de
réapprovisionnement, ni délai fournisseur. La couverture est un scénario à
rythme constant, pas une date de rupture prévue. Elle ne mesure pas non plus
les ventes perdues pendant une rupture ou les variations saisonnières.

## Validation effectuée

Les trois requêtes ont été exécutées sur une instance PostgreSQL temporaire
avec le schéma et le jeu de données du dépôt. Des assertions SQL ont vérifié
les totaux et les résultats principaux, ainsi que des cas calculés à la main :
tables vides, clients sans achat ou avec seulement des commandes annulées,
plusieurs lignes du même produit, achats le même jour, prix historiques
différents du catalogue, bornes de la fenêtre de 90 jours, seuil exact de
30 jours et produits sans vente. Les fixtures de vérification ont été annulées
en fin de transaction. Le script d'analyse peut aussi être exécuté dans une
transaction en lecture seule.

## État des branches lors de la découverte

Inspection après actualisation du dépôt distant, le **8 octobre 2026**.
La branche `galyst/partie-7` part de `main` (`668d3cf`).

| Branche distante | Contenu observé |
| --- | --- |
| `main` | Schéma et données ; `analysis.sql` vide |
| `matteo` | Même état que `main` |
| `modibo` | Même état que `main` |
| `saif` | Même état que `main` |
| `yazid` | Exercices 1–10, README de démarrage et sujet Word |
| `meziane` | Exploration des tables et indicateurs sur les 30 derniers jours, partie 6 |
| `simone` | Exercice 14 dans un fichier séparé contenant une sortie de terminal |
| `part5-exo14` | Exercice 14 et explication métier dans `analysis.sql` |

Cette branche apporte la partie 7 dans `analysis.sql`. Lors de l'intégration
du groupe, conserver ces trois requêtes après les parties précédentes et
fusionner les conclusions du README. Les autres contributions restent à
intégrer depuis leurs branches respectives.
