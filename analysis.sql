<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
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


--EXO 11 :

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

-- Exercice 12 - Analyse temporelle

-- CA par mois
SELECT TO_CHAR(co.date_commande, 'YYYY-MM') AS mois,
       SUM(lc.quantite * lc.prix_unitaire) AS chiffre_affaires
FROM commande co
JOIN ligne_commande lc ON lc.commande_id = co.id
WHERE co.statut <> 'annulée'
GROUP BY TO_CHAR(co.date_commande, 'YYYY-MM')
ORDER BY mois;

--Partie 5 — Qualité des données

--Exercice 13 — Détecter une incohérence
--Rechercher les commandes dont la date est antérieure à la date d'inscription du client.
--Pour chaque anomalie, afficher au minimum :
--l'identifiant de la commande ;
--l'identifiant du client ;
--la date de commande ;
--la date d'inscription.
--Vous devez également indiquer combien d'anomalies ont été détectées.

SELECT commande.id AS commande_id,
       client.id AS client_id,
       commande.date_commande,
       client.date_inscription
FROM commande
JOIN client ON commande.client_id = client.id
WHERE commande.date_commande < client.date_inscription;

SELECT COUNT(*) AS nombre_anomalies
FROM commande
JOIN client ON commande.client_id = client.id
WHERE commande.date_commande < client.date_inscription;



--EXO 14: Produits sans vente

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


--PARTIE 6 — Analyse de la qualité des données

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
-- Partie 7 — Analyse libre — Galyst
-- ============================================================
-- Chaque requête est indépendante et ne modifie aucune donnée.
-- Périmètre : commandes payées, expédiées ou livrées.
-- Montant d'une ligne = quantite * prix_unitaire (prix historique).
-- Les résultats et leur interprétation figurent dans README.md.

-- 7.1 — Quelle place occupent les clients qui achètent plusieurs fois ?
-- Données : client.id, commande (id, client_id, date_commande, statut),
-- ligne_commande (commande_id, quantite, prix_unitaire).
-- Les commandes sont agrégées AVANT les clients pour éviter de compter
-- une commande plusieurs fois lorsqu'elle contient plusieurs lignes.
-- Le délai moyen porte sur les intervalles entre achats successifs,
-- pondérés par le nombre d'intervalles, et non par le nombre de clients.
WITH commandes_valides AS (
    SELECT c.id, c.client_id, c.date_commande,
           COALESCE(SUM(lc.quantite * lc.prix_unitaire), 0) AS montant
    FROM commande AS c
    LEFT JOIN ligne_commande AS lc ON lc.commande_id = c.id
    WHERE c.statut <> 'annulée'
    GROUP BY c.id, c.client_id, c.date_commande
), achats_successifs AS (
    SELECT client_id, montant,
           date_commande - LAG(date_commande) OVER (
               PARTITION BY client_id ORDER BY date_commande, id
           ) AS delai_jours
    FROM commandes_valides
), bilan_clients AS (
    SELECT cl.id, COUNT(a.client_id) AS nombre_commandes,
           COALESCE(SUM(a.montant), 0) AS chiffre_affaires,
           COALESCE(SUM(a.delai_jours), 0) AS total_delai_jours,
           COUNT(a.delai_jours) AS nombre_intervalles
    FROM client AS cl
    LEFT JOIN achats_successifs AS a ON a.client_id = cl.id
    GROUP BY cl.id
), segments AS (
    SELECT *, CASE
        WHEN nombre_commandes = 0 THEN 0
        WHEN nombre_commandes = 1 THEN 1
        WHEN nombre_commandes BETWEEN 2 AND 4 THEN 2
        ELSE 3
    END AS ordre_segment
    FROM bilan_clients
), synthese AS (
    SELECT ordre_segment, COUNT(*) AS nombre_clients,
           SUM(nombre_commandes) AS nombre_commandes,
           SUM(chiffre_affaires) AS chiffre_affaires,
           SUM(total_delai_jours) AS total_delai_jours,
           SUM(nombre_intervalles) AS nombre_intervalles
    FROM segments
    GROUP BY ordre_segment
)
SELECT CASE ordre_segment
           WHEN 0 THEN 'Aucun achat non annulé'
           WHEN 1 THEN '1 achat'
           WHEN 2 THEN '2 à 4 achats'
           ELSE '5 achats ou plus'
       END AS segment,
       nombre_clients,
       ROUND(100.0 * nombre_clients / NULLIF(SUM(nombre_clients) OVER (), 0), 2)
           AS part_clients_pct,
       nombre_commandes, chiffre_affaires,
       ROUND(100.0 * chiffre_affaires / NULLIF(SUM(chiffre_affaires) OVER (), 0), 2)
           AS part_ca_pct,
       ROUND(total_delai_jours::numeric / NULLIF(nombre_intervalles, 0), 2)
           AS delai_moyen_entre_achats_jours
FROM synthese
ORDER BY ordre_segment;

-- 7.2 — Quels produits sont achetés ensemble plus souvent qu'attendu ?
-- Données : commande (id, statut), ligne_commande (commande_id, produit_id),
-- produit (id, nom). Une paire est comptée une fois par commande,
-- même si un produit apparaît sur plusieurs lignes ou en plusieurs unités.
-- Support = commandes contenant A et B / commandes non annulées.
-- Confiance A -> B = commandes contenant A et B / commandes contenant A.
-- Lift = support(A et B) / (support(A) * support(B)).
-- Seuil exploratoire : au moins 5 commandes communes ; 10 premiers lifts.
WITH commandes_valides AS (
    SELECT id FROM commande WHERE statut <> 'annulée'
), produits_par_commande AS (
    SELECT DISTINCT lc.commande_id, lc.produit_id
    FROM ligne_commande AS lc
    JOIN commandes_valides AS c ON c.id = lc.commande_id
), frequences AS (
    SELECT produit_id, COUNT(*) AS nombre_commandes
    FROM produits_par_commande
    GROUP BY produit_id
), paires AS (
    SELECT a.produit_id AS produit_a_id, b.produit_id AS produit_b_id,
           COUNT(*) AS commandes_communes
    FROM produits_par_commande AS a
    JOIN produits_par_commande AS b
      ON b.commande_id = a.commande_id AND a.produit_id < b.produit_id
    GROUP BY a.produit_id, b.produit_id
    HAVING COUNT(*) >= 5
), total AS (
    SELECT COUNT(*) AS nombre_commandes FROM commandes_valides
), indicateurs AS (
    SELECT p.*, fa.nombre_commandes AS commandes_avec_a,
           fb.nombre_commandes AS commandes_avec_b,
           100.0 * p.commandes_communes / NULLIF(t.nombre_commandes, 0)
               AS support_pct,
           100.0 * p.commandes_communes / NULLIF(fa.nombre_commandes, 0)
               AS confiance_a_vers_b_pct,
           100.0 * p.commandes_communes / NULLIF(fb.nombre_commandes, 0)
               AS confiance_b_vers_a_pct,
           p.commandes_communes::numeric * t.nombre_commandes
               / NULLIF(fa.nombre_commandes::numeric * fb.nombre_commandes, 0)
               AS lift
    FROM paires AS p
    JOIN frequences AS fa ON fa.produit_id = p.produit_a_id
    JOIN frequences AS fb ON fb.produit_id = p.produit_b_id
    CROSS JOIN total AS t
)
SELECT i.produit_a_id, pa.nom AS produit_a,
       i.produit_b_id, pb.nom AS produit_b,
       i.commandes_communes, i.commandes_avec_a, i.commandes_avec_b,
       ROUND(i.support_pct, 2) AS support_pct,
       ROUND(i.confiance_a_vers_b_pct, 2) AS confiance_a_vers_b_pct,
       ROUND(i.confiance_b_vers_a_pct, 2) AS confiance_b_vers_a_pct,
       ROUND(i.lift, 2) AS lift
FROM indicateurs AS i
JOIN produit AS pa ON pa.id = i.produit_a_id
JOIN produit AS pb ON pb.id = i.produit_b_id
ORDER BY i.lift DESC, i.commandes_communes DESC, i.produit_a_id, i.produit_b_id
LIMIT 10;

-- 7.3 — Quels stocks examiner en priorité au rythme des ventes récentes ?
-- Données : produit (id, nom, categorie, stock), commande (id, date_commande,
-- statut), ligne_commande (commande_id, produit_id, quantite).
-- Fenêtre de 90 jours calendaires, bornes incluses : dernière date de
-- commande du jeu de données moins 89 jours, jusqu'à cette dernière date.
-- La date de référence inclut les commandes annulées pour garder une borne
-- commune à tout le jeu. Aucun recours à CURRENT_DATE, pour être reproductible.
-- Couverture indicative = stock / (quantités vendues dans la fenêtre / 90).
-- Le stock n'est pas daté : il s'agit d'un scénario à rythme constant,
-- pas d'une prévision de rupture. Seuil de priorité choisi : moins de 30 jours.
WITH periode AS (
    SELECT MAX(date_commande) AS date_reference,
           MAX(date_commande) - 89 AS debut_periode
    FROM commande
), ventes_recentes AS (
    SELECT lc.produit_id, SUM(lc.quantite) AS quantite_vendue_90j
    FROM ligne_commande AS lc
    JOIN commande AS c ON c.id = lc.commande_id
    CROSS JOIN periode AS pe
    WHERE c.statut <> 'annulée'
      AND c.date_commande BETWEEN pe.debut_periode AND pe.date_reference
    GROUP BY lc.produit_id
), couverture AS (
    SELECT p.id, p.nom, p.categorie, p.stock,
           pe.debut_periode, pe.date_reference,
           COALESCE(v.quantite_vendue_90j, 0) AS quantite_vendue_90j,
           90.0 * p.stock / NULLIF(v.quantite_vendue_90j, 0) AS couverture_jours
    FROM produit AS p
    LEFT JOIN ventes_recentes AS v ON v.produit_id = p.id
    CROSS JOIN periode AS pe
)
SELECT id AS produit_id, nom AS produit, categorie, stock,
       debut_periode, date_reference, quantite_vendue_90j,
       ROUND(quantite_vendue_90j / 90.0, 2) AS quantite_moyenne_par_jour,
       ROUND(couverture_jours, 2) AS couverture_jours,
       CASE
           WHEN quantite_vendue_90j = 0 THEN 'Aucune vente récente'
           WHEN stock = 0 THEN 'Stock nul avec ventes récentes'
           WHEN couverture_jours < 30 THEN 'Couverture inférieure à 30 jours'
           ELSE 'Couverture de 30 jours ou plus'
       END AS situation
FROM couverture
ORDER BY CASE
             WHEN quantite_vendue_90j = 0 THEN 3
             WHEN stock = 0 THEN 0
             WHEN couverture_jours < 30 THEN 1
             ELSE 2
         END,
         couverture_jours NULLS LAST, quantite_vendue_90j DESC, id;
