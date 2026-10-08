DROP TABLE IF EXISTS ligne_commande CASCADE;
DROP TABLE IF EXISTS commande CASCADE;
DROP TABLE IF EXISTS produit CASCADE;
DROP TABLE IF EXISTS client CASCADE;

-- CLIENTS
CREATE SEQUENCE client_id_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE client (
    id               INTEGER PRIMARY KEY,
    nom              VARCHAR(100) NOT NULL,
    prenom           VARCHAR(100) NOT NULL,
    email            VARCHAR(255) NOT NULL UNIQUE,
    ville            VARCHAR(100) NOT NULL,
    date_inscription DATE NOT NULL
);

-- PRODUITS
CREATE SEQUENCE produit_id_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE produit (
    id        INTEGER PRIMARY KEY,
    nom       VARCHAR(150) NOT NULL,
    categorie VARCHAR(100) NOT NULL,
    prix      DECIMAL(10,2) NOT NULL,
    stock     INTEGER NOT NULL
);

-- COMMANDES
CREATE SEQUENCE commande_id_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE commande (
    id            INTEGER PRIMARY KEY,
    client_id     INTEGER NOT NULL REFERENCES client(id),
    date_commande DATE NOT NULL,
    statut        VARCHAR(20) NOT NULL
                  CHECK (statut IN ('payée', 'expédiée', 'livrée', 'annulée'))
);

-- LIGNES DE COMMANDE
CREATE SEQUENCE ligne_commande_id_seq START WITH 1 INCREMENT BY 1;
CREATE TABLE ligne_commande (
    id            INTEGER PRIMARY KEY,
    commande_id   INTEGER NOT NULL REFERENCES commande(id) ON DELETE CASCADE,
    produit_id    INTEGER NOT NULL REFERENCES produit(id),
    quantite      INTEGER NOT NULL,
    prix_unitaire DECIMAL(10,2) NOT NULL
);