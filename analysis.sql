<<<<<<< HEAD
-- Exercice 1 : liste des produits.
SELECT nom, categorie, prix, stock
FROM produit
ORDER BY nom;

-- Produits dont le prix est strictement supérieur à 100 euros.
SELECT nom, categorie, prix, stock
FROM produit
WHERE prix > 100
ORDER BY prix DESC;

-- Exercice 2 : clients d'une ville (remplacer Paris si nécessaire).
SELECT id, nom, prenom, email, ville, date_inscription
FROM client
WHERE ville = 'Paris'
ORDER BY nom, prenom, id;

-- Nombre de clients par ville.
SELECT ville, COUNT(*) AS nombre_clients
FROM client
GROUP BY ville
ORDER BY ville;

-- Exercice 3 : commandes et informations des clients.
SELECT commande.id AS commande_id, commande.date_commande, commande.statut,
       client.id AS client_id, client.nom, client.prenom,
       client.email, client.ville, client.date_inscription
FROM commande
JOIN client ON commande.client_id = client.id
ORDER BY commande.date_commande, commande.id;


-- Exercice 4 : montant de chaque ligne, y compris les lignes annulées.
SELECT id AS ligne_id, commande_id, produit_id, quantite, prix_unitaire,
       quantite * prix_unitaire AS montant_ligne
FROM ligne_commande
ORDER BY commande_id, id;

-- Exercice 5 : montant de chaque commande, tous statuts confondus.

SELECT commande.id AS commande_id, commande.date_commande, commande.statut,
       COALESCE(SUM(ligne_commande.quantite * ligne_commande.prix_unitaire), 0)
           AS montant_total
FROM commande
LEFT JOIN ligne_commande ON commande.id = ligne_commande.commande_id
GROUP BY commande.id, commande.date_commande, commande.statut
ORDER BY commande.id;

-- Exercice 6 : chiffre d'affaires et quantités vendues par catégorie.
SELECT produit.categorie,
       SUM(ligne_commande.quantite * ligne_commande.prix_unitaire) AS chiffre_affaires,
       SUM(ligne_commande.quantite) AS quantite_totale_vendue
FROM produit
JOIN ligne_commande ON produit.id = ligne_commande.produit_id
JOIN commande ON ligne_commande.commande_id = commande.id
WHERE commande.statut <> 'annulée'
GROUP BY produit.categorie
ORDER BY chiffre_affaires DESC;

-- Exercice 7 : les 10 produits les plus vendus en quantité.
SELECT produit.id AS produit_id, produit.nom AS produit, produit.categorie,
       SUM(ligne_commande.quantite) AS quantite_totale_vendue
FROM produit
JOIN ligne_commande ON produit.id = ligne_commande.produit_id
JOIN commande ON ligne_commande.commande_id = commande.id
WHERE commande.statut <> 'annulée'
GROUP BY produit.id, produit.nom, produit.categorie
ORDER BY quantite_totale_vendue DESC, produit.id
LIMIT 10;

-- Exercice 8 : classement des produits par chiffre d'affaires.
SELECT produit.id AS produit_id, produit.nom AS produit, produit.categorie,
       SUM(ligne_commande.quantite * ligne_commande.prix_unitaire) AS chiffre_affaires
FROM produit
JOIN ligne_commande ON produit.id = ligne_commande.produit_id
JOIN commande ON ligne_commande.commande_id = commande.id
WHERE commande.statut <> 'annulée'
GROUP BY produit.id, produit.nom, produit.categorie
ORDER BY chiffre_affaires DESC, produit.id;

-- Exercice 9 : nombre de commandes et montant dépensé par client.

SELECT client.id AS client_id, client.nom, client.prenom,
       COUNT(DISTINCT commande.id) AS nombre_commandes,
       COALESCE(SUM(CASE
           WHEN commande.statut <> 'annulée'
           THEN ligne_commande.quantite * ligne_commande.prix_unitaire
           ELSE 0
       END), 0) AS montant_total_depense
FROM client
LEFT JOIN commande ON client.id = commande.client_id
LEFT JOIN ligne_commande ON commande.id = ligne_commande.commande_id
GROUP BY client.id, client.nom, client.prenom
ORDER BY montant_total_depense DESC, client.id;

-- Clients n'ayant jamais passé de commande, quel que soit le statut.
SELECT client.id, client.nom, client.prenom, client.email, client.ville
FROM client
LEFT JOIN commande ON client.id = commande.client_id
WHERE commande.id IS NULL
ORDER BY client.id;

-- Exercice 10 : panier moyen global.
WITH montants_commandes AS (
    SELECT commande.id,
           COALESCE(SUM(ligne_commande.quantite * ligne_commande.prix_unitaire), 0)
               AS montant_total
    FROM commande
    LEFT JOIN ligne_commande ON commande.id = ligne_commande.commande_id
    WHERE commande.statut <> 'annulée'
    GROUP BY commande.id
)
SELECT COALESCE(SUM(montant_total), 0) AS chiffre_affaires,
       COUNT(*) AS nombre_commandes,
       ROUND(AVG(montant_total), 2) AS panier_moyen
FROM montants_commandes;

-- Panier moyen par mois : l'année est conservée pour distinguer les années.
WITH montants_commandes AS (
    SELECT commande.id, commande.date_commande,
           COALESCE(SUM(ligne_commande.quantite * ligne_commande.prix_unitaire), 0)
               AS montant_total
    FROM commande
    LEFT JOIN ligne_commande ON commande.id = ligne_commande.commande_id
    WHERE commande.statut <> 'annulée'
    GROUP BY commande.id, commande.date_commande
)
SELECT DATE_TRUNC('month', date_commande)::date AS mois,
       SUM(montant_total) AS chiffre_affaires,
       COUNT(*) AS nombre_commandes,
       ROUND(AVG(montant_total), 2) AS panier_moyen
FROM montants_commandes
GROUP BY DATE_TRUNC('month', date_commande)::date
ORDER BY mois;


EXO 11 :

-- Partie 1 : la catégorie de chaque commande
WITH montants AS (
    SELECT
        c.id AS commande_id,
        c.date_commande,
        c.statut,
        SUM(lc.quantite * lc.prix_unitaire) AS montant_total
    FROM commande c
    JOIN ligne_commande lc ON lc.commande_id = c.id
    WHERE c.statut <> 'annulée'
    GROUP BY c.id, c.date_commande, c.statut
)
SELECT
    commande_id,
    date_commande,
    statut,
    montant_total,
    CASE
        WHEN montant_total < 500  THEN 'Petit panier'
        WHEN montant_total < 1500 THEN 'Panier moyen'
        ELSE 'Gros panier'
    END AS categorie_panier
FROM montants
ORDER BY commande_id;

-- Partie 2 : répartition des commandes par catégorie
WITH montants AS (
    SELECT
        c.id AS commande_id,
        SUM(lc.quantite * lc.prix_unitaire) AS montant_total
    FROM commande c
    JOIN ligne_commande lc ON lc.commande_id = c.id
    WHERE c.statut <> 'annulée'
    GROUP BY c.id
)
SELECT
    CASE
        WHEN montant_total < 500  THEN 'Petit panier'
        WHEN montant_total < 1500 THEN 'Panier moyen'
        ELSE 'Gros panier'
    END AS categorie_panier,
    COUNT(*) AS nb_commandes,
    ROUND(SUM(montant_total), 2) AS chiffre_affaires
FROM montants
GROUP BY categorie_panier
ORDER BY MIN(montant_total);
>>>>>>> origin/saif
