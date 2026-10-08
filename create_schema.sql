-- =====================================================
-- SUPPRESSION DES TABLES
-- =====================================================

DROP TABLE IF EXISTS ligne_commande CASCADE;
DROP TABLE IF EXISTS commande CASCADE;
DROP TABLE IF EXISTS produit CASCADE;
DROP TABLE IF EXISTS client CASCADE;


-- =====================================================
-- CLIENTS
-- =====================================================

CREATE TABLE client (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    ville VARCHAR(100) NOT NULL,
    date_inscription DATE NOT NULL
);


-- =====================================================
-- PRODUITS
-- =====================================================

CREATE TABLE produit (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nom VARCHAR(150) NOT NULL,
    categorie VARCHAR(100) NOT NULL,
    prix DECIMAL(10,2) NOT NULL CHECK (prix >= 0),
    stock INTEGER NOT NULL CHECK (stock >= 0)
);


-- =====================================================
-- COMMANDES
-- =====================================================

CREATE TABLE commande (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    client_id INTEGER NOT NULL
        REFERENCES client(id),
    date_commande DATE NOT NULL,
    statut VARCHAR(20) NOT NULL
        CHECK (statut IN ('payée', 'expédiée', 'livrée', 'annulée'))
);


-- =====================================================
-- LIGNES DE COMMANDE
-- =====================================================

CREATE TABLE ligne_commande (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    commande_id INTEGER NOT NULL
        REFERENCES commande(id)
        ON DELETE CASCADE,
    produit_id INTEGER NOT NULL
        REFERENCES produit(id),
    quantite INTEGER NOT NULL CHECK (quantite > 0),
    prix_unitaire DECIMAL(10,2) NOT NULL CHECK (prix_unitaire >= 0)
);