Exercice 14: Produits sans vente

SELECT
    p.nom AS produit,
    p.categorie,
    p.prix,
    p.stock
FROM produit p
LEFT JOIN ligne_commande lc
    ON p.id = lc.produit_id
WHERE lc.produit_id IS NULL;


-- Explication métier :
-- Identifier les produits qui n'ont jamais été vendus permet à l'entreprise
-- de repérer ceux qui ne rencontrent aucune demande sur le marché dans un premier temps.
-- Cela peut être dû à un manque d'intérêt des clients, à une mauvaise stratégie
-- marketing ou à une concurrence accrue.
-- En identifiant ces produits, l'entreprise peut prendre des mesures pour améliorer
-- leur visibilité, ajuster leur prix ou même envisager de les retirer de son catalogue.
-- Elle peut ainsi prendre des décisions commerciales, comme lancer une promotion,
-- modifier le prix ou réduire le stock, afin de limiter les produits invendus.