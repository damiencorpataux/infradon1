--
-- Voici quelques essais.
--

-- Structure de base de données
CREATE DATABASE test;
CREATE TABLE person (
  id SERIAL PRIMARY KEY, 
  name1 VARCHAR(10) NOT NULL,
  name2 VARCHAR(10)
);

-- Données
INSERT INTO person (name1, name2) VALUES ('12345678901234567890', '12345678901234567890');
INSERT INTO person (name1, name2) VALUES ('', '1234567890');
INSERT INTO person (name1, name2) VALUES (NULL, '1234567890');
INSERT INTO person (name1, name2) VALUES ('1234567890', NULL);
INSERT INTO person (name1, name2) VALUES (NULL, NULL);
