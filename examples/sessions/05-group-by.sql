\connect postgres
DROP DATABASE IF EXISTS session05;
CREATE DATABASE session05;
\connect session05

CREATE TABLE status (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE contact (
    id SERIAL NOT NULL PRIMARY KEY,
    name TEXT NOT NULL,
    status_id INTEGER REFERENCES status(id)
);

INSERT INTO status (name) VALUES
    ('Online'),
    ('Offline');

INSERT INTO contact (name, status_id) VALUES
    ('Toto', 1),
    ('Tata', 1),
    ('Titi', 2),
    ('Tutu', NULL);


CREATE VIEW view_contact_status AS
    SELECT
        contact.id AS contact_id,
        status.id AS status_id,
        contact.name AS contact_name,
        status.name AS status_name
    FROM contact
    JOIN status ON contact.status_id = status.id;

SELECT * FROM view_contact_status;

SELECT
    status_id, 
    COUNT(*)
FROM view_contact_status
GROUP BY status_id;

SELECT
    status_id,
    status_name
    COUNT(*) AS contacts_count,
FROM view_contact_status
GROUP BY status_id, status_name;

SELECT 
    status_id,
    status_name,
    COUNT(*) AS contacts_count,
    STRING_AGG(contact_name, ', ') AS contact_names
FROM view_contact_status
GROUP BY status_id, status_name;
