-- ============================================================
-- Question :
-- Identifier les clients ayant généré le plus de chiffre
-- d'affaires et présenter au minimum les 10 premiers.
--
-- Le chiffre d'affaires est calculé à partir de la quantité
-- de produits commandés multipliée par leur prix unitaire.
-- Les commandes annulées ne sont pas prises en compte.
-- Les clients sont ensuite classés par chiffre d'affaires
-- décroissant afin d'obtenir les 10 meilleurs clients.
-- ============================================================

SELECT
    c.id,
    c.nom,
    c.prenom,
    c.email,
    SUM(lc.quantite * lc.prix_unitaire) AS chiffre_affaires
FROM client c
JOIN commande co
    ON co.client_id = c.id
JOIN ligne_commande lc
    ON lc.commande_id = co.id
WHERE co.statut IN ('payee', 'expediee', 'livree')
GROUP BY
    c.id,
    c.nom,
    c.prenom,
    c.email
ORDER BY chiffre_affaires DESC
LIMIT 10;

-- ============================================================
-- Question :
-- Créer une table synthese_mensuelle contenant, pour chaque
-- mois :
--   - le nombre de commandes ;
--   - le chiffre d'affaires ;
--   - le panier moyen.
--
-- Les commandes annulées ne sont pas prises en compte.
--
-- Cette table permet d'observer l'évolution mensuelle de
-- l'activité commerciale : évolution du nombre de commandes,
-- du chiffre d'affaires et du montant moyen dépensé par
-- commande.
-- ============================================================

DROP TABLE IF EXISTS synthese_mensuelle;

CREATE TABLE synthese_mensuelle AS
SELECT
    DATE_TRUNC('month', co.date_commande)::DATE AS mois,
    COUNT(DISTINCT co.id) AS nombre_commandes,
    SUM(lc.quantite * lc.prix_unitaire) AS chiffre_affaires,
    SUM(lc.quantite * lc.prix_unitaire)
        / COUNT(DISTINCT co.id) AS panier_moyen
FROM commande co
JOIN ligne_commande lc
    ON lc.commande_id = co.id
WHERE co.statut IN ('payee', 'expediee', 'livree')
GROUP BY DATE_TRUNC('month', co.date_commande)
ORDER BY mois;

-- Pour visualiser le resultat faites juste select * from synthese_mensuelle



-- ============================================================
-- NOTE IMPORTANTE SUR L'ENCODAGE :
--
-- Les valeurs du champ "statut" sont volontairement écrites
-- sans accents : payee, expediee, livree, annulee.
--
-- Cette décision a été prise afin d'éviter les problèmes
-- d'encodage rencontrés lors de l'importation des données.
--
-- La contrainte CHECK a donc été adaptée pour utiliser
-- exactement les mêmes valeurs sans accents.
-- ============================================================

-- Modification de la contrainte initiale :
--
-- ALTER TABLE commande
-- DROP CONSTRAINT commande_statut_check;
--
-- ALTER TABLE commande
-- ADD CONSTRAINT commande_statut_check
-- CHECK (statut IN ('payee', 'expediee', 'livree', 'annulee'));

-- ============================================================

