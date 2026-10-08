Partie 5 — Qualité des données
La qualité des données est également une problématique importante pour l'entreprise.
Exercice 13 — Détecter une incohérence
Rechercher les commandes dont la date est antérieure à la date d'inscription du client.
Pour chaque anomalie, afficher au minimum :
●	l'identifiant de la commande ;
●	l'identifiant du client ;
●	la date de commande ;
●	la date d'inscription.
Vous devez également indiquer combien d'anomalies ont été détectées.

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