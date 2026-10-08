# Analyse des données d'une plateforme e-commerce

Projet SQL réalisé en groupe dans le cadre de la formation **Data Engineering & IA**.

## Objectif

Concevoir une base de données relationnelle pour une plateforme e-commerce, importer les données fournies et réaliser des analyses SQL afin d'étudier les ventes, les clients, les produits, l'évolution de l'activité et la qualité des données.

## Technologies

- PostgreSQL
- SQL
- Git et GitHub (travail collaboratif)

## Organisation du dépôt

```text
projet-ecommerce/
├── create_schema.sql    # Création des tables et de leurs relations
├── seed_ecommerce.sql   # Données à importer
├── analysis.sql         # Requêtes d'analyse et indicateurs
├── README.md            # Documentation du projet
└── .gitignore           # Fichiers locaux à exclure (à ajouter si absent)
```

## Modèle de données

La base comporte quatre tables :

| Table | Rôle | Relations |
|---|---|---|
| `client` | Informations des clients et date d'inscription | Un client peut avoir plusieurs commandes |
| `produit` | Catalogue, catégorie, prix actuel et stock | Un produit peut figurer dans plusieurs lignes de commande |
| `commande` | Date, statut et client associé | `commande.client_id` → `client.id` |
| `ligne_commande` | Produits, quantités et prix réellement payés | `commande_id` → `commande.id` ; `produit_id` → `produit.id` |

Le prix utilisé pour le chiffre d'affaires est **`ligne_commande.prix_unitaire`**, et non le prix actuel du produit. Les commandes annulées sont exclues du chiffre d'affaires, des quantités vendues et du panier moyen.

## Installation et exécution

### 1. Récupérer le projet

```bash
git clone https://github.com/mballuais/projet-ecommerce.git
cd projet-ecommerce
```

**Prérequis :** PostgreSQL installé, serveur démarré, et accès à un rôle PostgreSQL autorisé à créer une base de données (ou base créée au préalable par un administrateur).

### 2. Créer la base de données

Depuis un terminal où les outils PostgreSQL sont accessibles :

```bash
createdb -U postgres ecommerce_db
```

Remplacer `postgres` par un rôle PostgreSQL disposant du droit de créer une base. Le propriétaire et les autorisations de la base doivent être configurés selon votre environnement.

### 3. Créer les tables

```bash
psql -U postgres -d ecommerce_db -v ON_ERROR_STOP=1 -f create_schema.sql
```

**Attention :** le fichier `create_schema.sql` présent dans le dépôt commence par des instructions `DROP TABLE`. Le relancer sur une base contenant déjà des données supprimera les tables concernées et leurs données. À utiliser sur une base neuve ou de test.

### 4. Charger les données

```bash
psql -U postgres -d ecommerce_db -v ON_ERROR_STOP=1 -f seed_ecommerce.sql
```

### 5. Vérifier le chargement

Dans `psql`, exécuter :

```sql
SELECT 'client' AS table_source, COUNT(*) AS nombre_lignes FROM client
UNION ALL
SELECT 'produit', COUNT(*) FROM produit
UNION ALL
SELECT 'commande', COUNT(*) FROM commande
UNION ALL
SELECT 'ligne_commande', COUNT(*) FROM ligne_commande;
```

### 6. Exécuter les analyses

```bash
psql -U postgres -d ecommerce_db -v ON_ERROR_STOP=1 -f analysis.sql
```

Les commandes ci-dessus utilisent `postgres` comme exemple de rôle PostgreSQL : adaptez-le à votre environnement. Elles supposent que `psql` et `createdb` sont accessibles depuis le terminal. Sous Windows, leur chemin complet peut être nécessaire.

## Analyses SQL

Le fichier `analysis.sql` regroupe les exercices du projet :

| Domaine | Analyses attendues |
|---|---|
| Exploration | Produits, clients, commandes, structure et valeurs manquantes |
| Ventes | Montants des lignes et commandes, CA par catégorie, top produits |
| Clients | Nombre de commandes, dépenses, clients sans commande, top 10 clients |
| Transformation | Catégories de paniers : moins de 500 €, de 500 à moins de 1 500 €, 1 500 € et plus |
| Temporalité | CA et panier moyen par mois, périodes fortes et faibles |
| Qualité des données | Commandes antérieures à l'inscription, produits sans vente |
| Tableau de bord | CA total, nombre de commandes, panier moyen, clients actifs, taux d'annulation |
| Synthèse mensuelle | Table `synthese_mensuelle` créée avec `CREATE TABLE ... AS SELECT` |
| Analyse libre | Au moins trois analyses complémentaires et leur interprétation |

**Règles de calcul :**

- Montant d'une ligne = `quantite * prix_unitaire`.
- Chiffre d'affaires = somme des montants des lignes des commandes non annulées.
- Panier moyen = chiffre d'affaires / nombre de commandes non annulées prises en compte.
- Taux d'annulation = nombre de commandes annulées / nombre total de commandes × 100.

## Principales conclusions

> **Section à compléter avec les résultats réellement obtenus après exécution de `analysis.sql`.** Ne pas présenter ces observations comme acquises avant vérification.

| Indicateur ou observation | Résultat à renseigner |
|---|---|
| Chiffre d'affaires total | À compléter |
| Nombre de commandes non annulées | À compléter |
| Panier moyen | À compléter |
| Nombre de clients actifs | À compléter |
| Taux d'annulation | À compléter |
| Catégorie générant le plus de CA | À compléter |
| Produit le plus vendu | À compléter |
| Mois le plus performant | À compléter |
| Anomalies de dates détectées | À compléter |
| Produits sans vente | À compléter |

**Interprétation métier à rédiger :** préciser ce que ces résultats révèlent sur l'activité, les opportunités commerciales et les éventuels problèmes de qualité des données.

### Analyses complémentaires (partie libre)

À compléter avec **trois questions différentes de celles déjà traitées**. Pour chacune, documenter la question, les tables utilisées, la requête dans `analysis.sql`, le résultat observé et son intérêt pour l'entreprise.

## Travail collaboratif

Le projet est suivi avec Git et GitHub. Les membres du groupe peuvent travailler sur des branches dédiées, puis proposer leurs modifications au moyen de *pull requests* pour faciliter la relecture et la fusion.

**Dépôt :** https://github.com/mballuais/projet-ecommerce

---

*Projet pédagogique — Analyse SQL d'une plateforme e-commerce.*
