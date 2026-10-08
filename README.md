# EFREI — Projet de groupe : analyse des données d'une plateforme e-commerce

Projet noté, à réaliser en groupe et entièrement en SQL (PostgreSQL).

## Contenu

- `Projet équipe_SQL.docx` : le sujet complet (consignes, exercices, livrables, barème).
- `seed_ecommerce.sql` : les données de la plateforme (clients, produits, commandes, lignes de commande).

## Démarrage

0. Récupérez les fichiers :

```bash
git clone https://github.com/Louis-skillshield/projet-groupe.git
```

1. Lisez le sujet en entier avant de commencer.
2. Créez votre propre dépôt GitHub de groupe et copiez-y `seed_ecommerce.sql`.
3. Écrivez votre `create_schema.sql` (partie 1 du sujet), puis chargez les données :

```bash
createdb -U {username} ecommerce_db
psql -U {username} -d ecommerce_db -f create_schema.sql
psql -U {username} -d ecommerce_db -f seed_ecommerce.sql
```

Remplacez `{username}` par votre utilisateur PostgreSQL.

`seed_ecommerce.sql` doit être exécuté **après** la création des tables :
les noms de tables et de colonnes doivent correspondre à ceux utilisés dans le fichier.