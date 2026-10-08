# Projet e-commerce — Partie 7

**Galyst — Analyse libre**

Les trois requêtes sont dans `analysis.sql`. Les commandes annulées sont
exclues, et le chiffre d'affaires est calculé avec le prix payé dans chaque
ligne de commande : `quantite * prix_unitaire`.

## Lancer le projet

Avec PostgreSQL démarré, remplacer `votre_utilisateur` par votre utilisateur.
À faire sur une base neuve : le script de création supprime les tables existantes.

```bash
createdb -U votre_utilisateur ecommerce_db
psql -U votre_utilisateur -d ecommerce_db -v ON_ERROR_STOP=1 -f create_schema.sql
psql -U votre_utilisateur -d ecommerce_db -v ON_ERROR_STOP=1 -f seed_ecommerce.sql
```

Si les données sont déjà chargées, lancer seulement les analyses :

```bash
psql -U votre_utilisateur -d ecommerce_db -v ON_ERROR_STOP=1 -f analysis.sql
```

Le jeu de données contient 100 clients, 65 produits, 500 commandes et
1 547 lignes de commande.

## 1. Les clients reviennent-ils acheter ?

On utilise les tables `client`, `commande` et `ligne_commande` pour compter
les achats par client et leur montant. La fonction `LAG` permet de calculer
le nombre de jours entre deux achats.

| Nombre d'achats | Clients | Part du chiffre d'affaires | Délai moyen entre achats |
| --- | ---: | ---: | ---: |
| Aucun achat non annulé | 10 | 0 % | — |
| 1 achat | 2 | 0,26 % | — |
| 2 à 4 achats | 34 | 22,71 % | 75,26 jours |
| 5 achats ou plus | 54 | 77,04 % | 45,85 jours |

Les 54 clients ayant acheté au moins cinq fois représentent 77,04 % du CA.
Ils reviennent aussi plus rapidement que ceux ayant fait deux à quatre achats.
Cela peut aider à choisir quels clients fidéliser et quand relancer ceux qui
achètent moins souvent. Ces chiffres concernent uniquement la période du jeu
de données : tous les clients ne sont pas inscrits depuis aussi longtemps.

## 2. Quels produits sont achetés ensemble ?

On utilise `commande`, `ligne_commande` et `produit` pour repérer les produits
achetés ensemble, hors commandes annulées. Chaque paire compte une seule fois
par commande. On garde celles
présentes dans au moins cinq commandes et on les classe par **lift** : au-dessus
de 1, les produits sont associés plus souvent que si leurs achats étaient
indépendants.

Extrait des résultats :

| Produit A | Produit B | Commandes communes | Lift |
| --- | --- | ---: | ---: |
| Hub USB 2 | Veste 2 | 6 | 4,51 |
| SSD 1 | Barre de son 2 | 5 | 3,63 |
| Casque 2 | Bouilloire 1 | 6 | 3,59 |

Hub USB 2 et Veste 2 ont le lift le plus élevé, mais ils ne sont présents
ensemble que dans six commandes sur 484. Ces résultats donnent des idées de
produits à proposer ensemble. Il faut quand même rester prudent : cinq ou
six commandes ne suffisent pas pour confirmer une tendance.

## 3. Quels stocks faut-il surveiller ?

On compare le stock de chaque produit aux quantités vendues du **1er octobre
au 29 décembre 2025**, les 90 derniers jours du jeu de données. On utilise
`produit.stock`, les dates des commandes et les quantités des lignes.

Le calcul est : `stock × 90 / quantité vendue sur 90 jours`.
Il estime combien de jours le stock pourrait durer au même rythme de vente.

| Produit | Stock | Quantité vendue sur 90 jours | Couverture estimée |
| --- | ---: | ---: | ---: |
| Lampe 2 | 0 | 16 | 0 jour |
| Souris 2 | 0 | 10 | 0 jour |
| Sweat 1 | 0 | 9 | 0 jour |
| Haltères 1 | 1 | 6 | 15 jours |
| Enceinte 1 | 7 | 25 | 25,20 jours |

Trois produits ont un stock nul malgré des ventes récentes. Haltères 1 et
Enceinte 1 ont une couverture inférieure à 30 jours. Ce sont donc les premiers
produits dont il faudrait vérifier le réapprovisionnement.

Cinq produits n'ont aucune vente récente : on ne peut pas calculer leur
couverture. Cette estimation reste indicative, car on ne connaît ni la date
du relevé de stock ni les délais de livraison des fournisseurs.
