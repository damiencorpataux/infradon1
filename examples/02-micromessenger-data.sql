-- Dans cet exemple, nous pouvons stocker des message entre contacts.
-- Nous pouvons ajouter la notion de groupe et de status de message.

-- Structure
\connect postgres
DROP DATABASE micromessenger;
CREATE DATABASE micromessenger;
\connect micromessenger

CREATE TABLE status (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE contact (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,  -- TODO: Create a UNIQUE INDEX that is case-insensitive, to refuse storing eg. 'Alice' and 'alice', see: https://stackoverflow.com/questions/4124185/postgresql-unique-indexes-and-string-case
    --statusline VARCHAR(150),  -- TODO: Add the possibility for a contact to yell statusline !
    status_id INTEGER DEFAULT 1,
    CONSTRAINT status_id FOREIGN KEY(status_id) REFERENCES status(id)
);

CREATE TABLE rel_message (
    id SERIAL PRIMARY KEY,
    creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    content TEXT NOT NULL,
    contact_id_source INTEGER NOT NULL,
    contact_id_destination INTEGER NOT NULL,
    CONSTRAINT contact_id_source FOREIGN KEY(contact_id_source) REFERENCES contact(id),
    CONSTRAINT contact_id_destination FOREIGN KEY(contact_id_destination) REFERENCES contact(id)
);

-- Iteration 2: Add group managment
-- CREATE TABLE group (
--     id SERIAL PRIMARY KEY,
--     name TEXT NOT NULL UNIQUE
--     creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
--     owner_contact_id INTEGER NOT NULL,
--     CONSTRAINT owner_contact_id FOREIGN KEY(owner_contact_id) REFERENCES contact(id)
-- );

-- CREATE TABLE rel_group_contacts (
--     id SERIAL PRIMARY KEY,
--     group_id INTEGER NOT NULL,
--     contact_id INTEGER NOT NULL,
--     CONSTRAINT group_id FOREIGN KEY(group_id) REFERENCES group(id),
--     CONSTRAINT contact_id FOREIGN KEY(contact_id) REFERENCES contact(id)
-- );

-- Iteration 3: Add message status managment
-- CREATE TABLE rel_isread_message_contact (
--     TODO: A n..n relationship table to hold information about who has read what.
--     NOTE: It could also be managed as a message status per contact (delivering, delivered, read)
-- )

CREATE VIEW view_contacts AS
    SELECT
        contact.id AS id,
        contact.name AS name,
        status.id AS status_id,
        status.name AS status_name
    FROM contact
    JOIN status ON status.id = contact.status_id;

CREATE VIEW view_messages AS
    SELECT
        rel_message.id AS id,
        rel_message.creation AS creation,
        rel_message.content AS content,
        contact_source.id AS contact_source_id,
        contact_source.name AS contact_source_name,
        contact_destination.id AS contact_destination_id,
        contact_destination.name AS contact_destination_name
    FROM rel_message
    JOIN contact AS contact_source ON rel_message.contact_id_source = contact_source.id
    JOIN contact AS contact_destination ON rel_message.contact_id_destination = contact_destination.id
    ORDER BY creation;


-- Sample data for testing
INSERT INTO status (name) VALUES ('Online');
INSERT INTO status (name) VALUES ('Offline');
INSERT INTO status (name) VALUES ('DND');

INSERT INTO contact (name, status_id) VALUES ('Alice', 1);
INSERT INTO contact (name, status_id) VALUES ('Bob', 1);
INSERT INTO contact (name, status_id) VALUES ('Peter', 2);

INSERT INTO rel_message (contact_id_source, contact_id_destination, content) VALUES (1, 2, 'Ping ?');
INSERT INTO rel_message (contact_id_source, contact_id_destination, content) VALUES (2, 1, 'Pong !');


-- Sample queries
SELECT * FROM contact JOIN status ON contact.status_id = status.id;

SELECT * FROM contact
  JOIN status ON contact.status_id = status.id
  JOIN rel_message ON rel_message.contact_id_source = contact.id;

SELECT * FROM view_contacts;
SELECT * FROM view_messages;