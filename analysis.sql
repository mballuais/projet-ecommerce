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
