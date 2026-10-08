# Analyse SQL d'une plateforme e-commerce

Projet de groupe — Modélisation, chargement et analyse de données commerciales avec **PostgreSQL**

## Objectif

Construire une base relationnelle pour une plateforme e-commerce et analyser ses ventes, ses clients, ses produits et la qualité de ses données. Les analyses sont réalisées en SQL.

## Structure du dépôt

```text
projet-ecommerce/
├── create_schema.sql   # Création des tables et des contraintes
├── seed_ecommerce.sql  # Jeu de données fourni
├── analysis.sql        # Requêtes d'analyse et indicateurs
└── README.md           # Documentation du projet
```

> Le sujet demande également un fichier `.gitignore`, à ajouter au dépôt si nécessaire.

## Modèle de données

La base comprend quatre tables :

| Table | Rôle |
| --- | --- |
| `client` | Identité, contact, ville et date d'inscription des clients |
| `produit` | Catalogue, catégorie, prix actuel et stock |
| `commande` | Commandes, client associé, date et statut |
| `ligne_commande` | Produits commandés, quantités et prix unitaire réellement payé |

**Relations :** `commande.client_id → client.id`, `ligne_commande.commande_id → commande.id`, `ligne_commande.produit_id → produit.id`.

Les statuts autorisés pour une commande sont : `payée`, `expédiée`, `livrée`, `annulée`.

## Prérequis

- PostgreSQL et l'outil en ligne de commande `psql` ;
- Git pour récupérer le dépôt ;
- un rôle PostgreSQL disposant des droits de création de base et de tables, ou une base créée par un administrateur.

Les exemples ci-dessous sont indépendants du système d'exploitation, sous réserve que `psql` et `createdb` soient accessibles dans le terminal.

## Installation et exécution

### 1. Récupérer le projet

```bash
git clone https://github.com/mballuais/projet-ecommerce.git
cd projet-ecommerce
```

### 2. Créer la base

```bash
createdb -U <utilisateur_postgresql> ecommerce_db
```

Si votre compte ne peut pas créer de base, demandez à un administrateur de créer `ecommerce_db` et de vous accorder les droits nécessaires.

### 3. Créer les tables

```bash
psql -U <utilisateur_postgresql> -d ecommerce_db -v ON_ERROR_STOP=1 -f create_schema.sql
```

**Attention :** `create_schema.sql` commence par des instructions `DROP TABLE IF EXISTS ... CASCADE`. Le rejouer sur une base déjà remplie supprime les tables et leurs données.

### 4. Charger les données

```bash
psql -U <utilisateur_postgresql> -d ecommerce_db -v ON_ERROR_STOP=1 -f seed_ecommerce.sql
```

### 5. Vérifier le chargement

```bash
psql -U <utilisateur_postgresql> -d ecommerce_db
```

Puis, dans `psql` :

```sql
\dt
SELECT COUNT(*) AS nombre_clients FROM client;
SELECT COUNT(*) AS nombre_produits FROM produit;
SELECT COUNT(*) AS nombre_commandes FROM commande;
SELECT COUNT(*) AS nombre_lignes FROM ligne_commande;
```

Quitter avec `\q`.

### 6. Exécuter les analyses

```bash
psql -U <utilisateur_postgresql> -d ecommerce_db -v ON_ERROR_STOP=1 -f analysis.sql
```

Pour exécuter une requête isolée, ouvrez `psql` et copiez la requête souhaitée depuis `analysis.sql`.

## Périmètre des analyses

Le fichier `analysis.sql` rassemble les travaux demandés :

- **Exploration :** produits, clients, commandes et volumes de données.
- **Ventes :** montant des lignes et commandes, chiffre d'affaires par catégorie, produits les plus vendus et les plus rémunérateurs.
- **Clients :** nombre de commandes, dépenses, clients sans commande et classement des meilleurs clients.
- **Évolution temporelle :** chiffre d'affaires et panier moyen par mois.
- **Transformation :** segmentation des commandes en petits, moyens et gros paniers.
- **Qualité des données :** commandes antérieures à l'inscription du client, produits sans vente et valeurs manquantes.
- **Tableau de bord :** chiffre d'affaires, commandes, panier moyen, clients actifs, taux d'annulation et synthèse mensuelle.
- **Analyse libre :** trois analyses complémentaires à documenter avec leur question métier, leurs résultats et leur intérêt.

### Règles de calcul

- Montant d'une ligne : `quantite × prix_unitaire`.
- Le chiffre d'affaires, les quantités vendues et le panier moyen **excluent les commandes annulées**.
- Le prix utilisé pour calculer le chiffre d'affaires est le **prix réellement payé**, conservé dans `ligne_commande.prix_unitaire`, et non le prix actuel du catalogue.
- Panier moyen : chiffre d'affaires / nombre de commandes retenues dans le calcul.

## Principales conclusions

> **À compléter après exécution et vérification des requêtes sur la base.** Ne pas remplacer ces champs par des estimations.

| Indicateur | Résultat |
| --- | --- |
| Chiffre d'affaires total | À compléter |
| Nombre de commandes retenues | À compléter |
| Panier moyen | À compléter |
| Clients actifs | À compléter |
| Taux d'annulation | À compléter |
| Catégorie générant le plus de CA | À compléter |
| Mois avec le CA le plus élevé | À compléter |
| Anomalies de dates détectées | À compléter |

**Interprétation commerciale :** à compléter avec les constats réellement observés (concentration du chiffre d'affaires, saisonnalité, comportement des clients, etc.).

**Qualité des données :** à compléter avec le nombre d'anomalies et les conséquences possibles sur les indicateurs.

**Analyses libres :** pour chacune des trois analyses supplémentaires, présenter la question, les données mobilisées, la requête SQL (dans `analysis.sql`), le résultat, l'observation et son intérêt pour l'entreprise.

## Travail collaboratif

Le projet est versionné avec Git et hébergé sur GitHub. Les modifications peuvent être proposées sur une branche dédiée puis intégrées après revue via une *pull request*.

## Remarques

- Aucune information de connexion personnelle ni aucun mot de passe ne doit être ajouté aux fichiers versionnés.
