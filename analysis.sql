-- Exercice 14: Produits sans vente

SELECT
    p.nom AS produit,
    p.categorie,
    p.prix,
    p.stock
FROM produit p
LEFT JOIN ligne_commande lc
    ON p.id = lc.produit_id
WHERE lc.produit_id IS NULL;