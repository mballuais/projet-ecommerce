ecommerce_db=> SELECT produit.nom,                                                                             
ecommerce_db-> produit.categorie,
ecommerce_db-> produit.prix,
ecommerce_db-> produit.stock 
ecommerce_db-> FROM produit
ecommerce_db-> LEFT JOIN ligne_commande ON produit.id = ligne_commande.produit_id
ecommerce_db-> WHERE ligne_commande.produit_id IS NULL;
        nom        |  categorie   |  prix  | stock                                                                                                                             
-------------------+--------------+--------+-------
 Imprimante 1      | Informatique | 189.90 |    42
 Platine vinyle 1  | Audio        | 279.00 |    18
 Grille-pain 1     | Maison       |  44.90 |    65
 Chemise 1         | Mode         |  49.90 |    80
 Corde ├á sauter 1 | Sport        |  19.90 |   120
(5 rows)

-- QUESTION : Puis expliquer pourquoi cette information peut être intéressante pour l'entreprise.
-- Identifier les produits jamais vendus permet à l'entreprise de repérer les produits qui ne génèrent aucune vente malgré leur présence au catalogue. 
-- Cela peut aider à décider de réduire leur stock, revoir leur prix à la baisse, activer une promotion ou retirer certains produits du catalogue. 