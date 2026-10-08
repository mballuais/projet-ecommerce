-- =============================
-- Exercice 12 - Analyse temporelle
-- =============================

-- CA par mois
SELECT TO_CHAR(co.date_commande, 'YYYY-MM') AS mois,
       SUM(lc.quantite * lc.prix_unitaire) AS chiffre_affaires
FROM commande co
JOIN ligne_commande lc ON lc.commande_id = co.id
WHERE co.statut <> 'annulée'
GROUP BY TO_CHAR(co.date_commande, 'YYYY-MM')
ORDER BY mois;