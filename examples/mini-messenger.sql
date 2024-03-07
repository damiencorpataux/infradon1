-- PostgreSQL 16
-- Conventions:
-- - Nommenclature:
--   - Champs, tables, etc: en anglais
--   - Clés étrangères: fk_<relationship>_<table>_<champ>


-- Structure de base de données
\connect postgres
DROP DATABASE messenger;
CREATE DATABASE messenger;
\connect messenger

CREATE TABLE status (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE contact (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    fk_status_id INTEGER DEFAULT 1,
    CONSTRAINT fk_status_id FOREIGN KEY(fk_status_id) REFERENCES status(id)
);

CREATE TABLE rel_message (
    id SERIAL PRIMARY KEY,
    content TEXT NOT NULL UNIQUE,
    fk_contact_id_source INTEGER NOT NULL,
    fk_contact_id_destination INTEGER NOT NULL,
    CONSTRAINT fk_contact_id_source FOREIGN KEY(fk_contact_id_source) REFERENCES contact(id),
    CONSTRAINT fk_contact_id_destination FOREIGN KEY(fk_contact_id_destination) REFERENCES contact(id)
);

-- Iteration 2: Add group managment
-- CREATE TABLE group (
--     id SERIAL PRIMARY KEY,
--     name TEXT NOT NULL UNIQUE
--     creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
--     fk_owner_contact_id INTEGER NOT NULL,
--     CONSTRAINT fk_owner_contact_id FOREIGN KEY(fk_owner_contact_id) REFERENCES contact(id)
-- );

-- CREATE TABLE rel_group_contacts (
--     id SERIAL PRIMARY KEY,
--     fk_group_id INTEGER NOT NULL,
--     fk_contact_id INTEGER NOT NULL,
--     CONSTRAINT fk_group_id FOREIGN KEY(fk_group_id) REFERENCES group(id),
--     CONSTRAINT fk_contact_id FOREIGN KEY(fk_contact_id) REFERENCES contact(id)
-- );

-- Iteration 3: Add message status managment
-- CREATE TABLE rel_isread_message_contact (
--     TODO: A n..n relationship table to hold information about who has read what.
--     NOTE: It could also be managed as a message status per contact (delivering, delivered, read)
-- )


-- Sample data for testing
INSERT INTO status (name) VALUES ('Online');
INSERT INTO status (name) VALUES ('Offline');
INSERT INTO status (name) VALUES ('DND');

INSERT INTO contact (name, fk_status_id) VALUES ('Alice', 1);
INSERT INTO contact (name, fk_status_id) VALUES ('Bob', 1);

INSERT INTO rel_message (fk_contact_id_source, fk_contact_id_destination) VALUES (1, 2);
INSERT INTO rel_message (fk_contact_id_source, fk_contact_id_destination) VALUES (2, 1);


-- Sample queries
SELECT * FROM contact JOIN status ON contact.fk_status_id = status.id;

SELECT * FROM contact
  JOIN status ON contact.fk_status_id = status.id
  JOIN rel_message ON rel_message.fk_contact_id_source = contact.id;

