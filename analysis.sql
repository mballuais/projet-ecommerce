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