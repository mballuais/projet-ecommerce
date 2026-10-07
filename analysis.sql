
--●	le nombre de lignes de chaque table ;
SELECT 'Clients' AS Nom_Table , COUNT(*) AS nb_lignes FROM client
UNION ALL
SELECT 'Produits' , COUNT(*) AS nb_lignes FROM produit
UNION ALL
SELECT 'Commandes' , COUNT(*) AS nb_lignes FROM commande
UNION ALL
SELECT 'Lignes de commande', COUNT(*) AS nb_lignes FROM ligne_commande
ORDER BY Nom_Table;

--●	les colonnes et leurs types de données 
SELECT table_name,
        column_name,
        data_type
FROM information_schema.columns
WHERE table_schema = 'public'  
ORDER BY table_name, ordinal_position;

--●	les éventuelles valeurs manquantes.
SELECT *
FROM (
    SELECT 'client' AS nom_table, 'nom' AS nom_colonne, COUNT(*) - COUNT(nom) AS nb_manquants FROM client
    UNION ALL
    SELECT 'client', 'prenom', COUNT(*) - COUNT(prenom) FROM client
    UNION ALL
    SELECT 'client', 'email', COUNT(*) - COUNT(email) FROM client
    UNION ALL
    SELECT 'client', 'ville', COUNT(*) - COUNT(ville) FROM client
    UNION ALL
    SELECT 'client', 'date_inscription', COUNT(*) - COUNT(date_inscription) FROM client
    UNION ALL
    SELECT 'produit', 'nom', COUNT(*) - COUNT(nom) FROM produit
    UNION ALL
    SELECT 'produit', 'categorie', COUNT(*) - COUNT(categorie) FROM produit
    UNION ALL
    SELECT 'produit', 'prix', COUNT(*) - COUNT(prix) FROM produit
    UNION ALL
    SELECT 'produit', 'stock', COUNT(*) - COUNT(stock) FROM produit
    UNION ALL
    SELECT 'commande', 'client_id', COUNT(*) - COUNT(client_id) FROM commande
    UNION ALL
    SELECT 'commande', 'date_commande', COUNT(*) - COUNT(date_commande) FROM commande
    UNION ALL
    SELECT 'commande', 'statut', COUNT(*) - COUNT(statut) FROM commande
    UNION ALL
    SELECT 'ligne_commande', 'commande_id', COUNT(*) - COUNT(commande_id) FROM ligne_commande
    UNION ALL
    SELECT 'ligne_commande', 'produit_id', COUNT(*) - COUNT(produit_id) FROM ligne_commande
    UNION ALL
    SELECT 'ligne_commande', 'quantite', COUNT(*) - COUNT(quantite) FROM ligne_commande
    UNION ALL
    SELECT 'ligne_commande', 'prix_unitaire', COUNT(*) - COUNT(prix_unitaire) FROM ligne_commande
) t
WHERE nb_manquants > 0
ORDER BY nom_table, nom_colonne;

--●	le chiffre d'affaires total ;
--●	le nombre de commandes ;
--●	le panier moyen ;
--●	le nombre de clients actifs.
--●	le taux d'annulation des commandes.


SELECT 
    SUM(CASE WHEN c.statut <> 'annulée' THEN prix_unitaire * quantite ELSE 0 END) AS chiffre_affaires, 
    COUNT(DISTINCT CASE WHEN c.statut <> 'annulée' THEN c.id END) AS nb_commandes,
    ROUND(SUM(CASE WHEN c.statut <> 'annulée' THEN prix_unitaire * quantite ELSE 0 END) / COUNT(DISTINCT CASE WHEN c.statut <> 'annulée' THEN c.id END), 2) AS panier_moyen,
    COUNT(DISTINCT c.client_id) AS nb_clients_actifs,
    COUNT(DISTINCT CASE WHEN c.statut = 'annulée' THEN c.id END) * 100.0 / COUNT(DISTINCT c.id) AS taux_annulation

FROM ligne_commande
JOIN commande c ON ligne_commande.commande_id = c.id
WHERE
      c.date_commande >= (SELECT MAX(date_commande) FROM commande) - INTERVAL '30 days';