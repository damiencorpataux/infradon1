-- Dans cet example, nous pouvons associer un type de relation primaire à un contact
-- et pouvons aussi y associer des types de relation secondaires.
-- Nous avons aussi un système de tags minimaliste.
-- TODO: Ajouter une notion de groupe.

\connect postgres
DROP DATABASE IF EXISTS contacts;

CREATE DATABASE contacts;
\connect contacts


-- Structure
CREATE TABLE relationship (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL
);



CREATE TABLE person (
    id SERIAL PRIMARY KEY,
    creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    label TEXT NOT NULL,
    relationship_id INTEGER NOT NULL DEFAULT 1,
    CONSTRAINT fk_relationship_id FOREIGN KEY(relationship_id) REFERENCES relationship(id)
);

CREATE TABLE rel_secondary_relationship (
    id SERIAL PRIMARY KEY,
    creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    person_id INTEGER NOT NULL,
    relationship_id INTEGER NOT NULL,
    CONSTRAINT fk_person_id FOREIGN KEY(person_id) REFERENCES person(id),
    CONSTRAINT fk_relationship_id FOREIGN KEY(relationship_id) REFERENCES relationship(id)
);

CREATE TABLE rel_attribute_person (
    id SERIAL PRIMARY KEY,
    creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    person_id INTEGER NOT NULL,
    name TEXT,  -- TODO: Make a catalog table.
    value TEXT
);


-- View: Let's create my view of persons !
CREATE VIEW view_person_relationship AS
    SELECT
        person.id AS id,
        person.creation AS creation,
        person.relationship_id AS relationship_primary_id,
        relationship_secondary.id AS relationship_secondary_id,
        rel_secondary_relationship AS rel_secondary_relationship_id,
        person.label AS label,
        relationship_primary.name AS relationship_primary_name,
        relationship_secondary.name AS relationship_secondary_name
    FROM person
        JOIN relationship AS relationship_primary ON relationship_primary.id = person.relationship_id
        JOIN rel_secondary_relationship ON rel_secondary_relationship.person_id = person.id
        JOIN relationship AS relationship_secondary ON relationship_secondary.id = rel_secondary_relationship.relationship_id;

-- View: Now create a view that lists all persons with all their attributes, it is a kind of contact managment
CREATE VIEW view_person_attribute AS
    SELECT
        rel_attribute_person.id AS id,
        rel_attribute_person.creation AS creation,
        person.id AS person_id,
        person.creation AS person_creation,
        rel_attribute_person.name AS name,
        rel_attribute_person.value AS value,
        person.label AS person_label
    FROM person
    JOIN rel_attribute_person ON rel_attribute_person.person_id = person.id;

CREATE VIEW view_person_flat AS
    SELECT
        person_id,
        person_creation,
        COUNT(person_id),
        STRING_AGG(name || ':' || value, ', ')
    FROM view_person_attribute
    GROUP BY person_id, person_creation;

CREATE VIEW view_person_json AS
    SELECT json_agg(subquery.*) AS combined_json
    FROM (
        SELECT
            person_id,
            to_char(person_creation, 'YYYY-MM-DD HH24:MI:SS') AS person_creation,
            person_label,
            json_agg(json_build_object(
                'name', name,
                'value', value,
                'creation', to_char(creation, 'YYYY-MM-DD HH24:MI:SS')
            )) AS attributes
        FROM
            view_person_attribute
        GROUP BY
            person_id, person_creation, person_label
    ) AS subquery;


-- Sample data
INSERT INTO relationship (name) VALUES
    ('Unknown'),
    ('Family'),
    ('Friend');

INSERT INTO person (label, relationship_id) VALUES ('Toto', 1);
-- INSERT INTO person (name) VALUES ('Titi');
INSERT INTO rel_secondary_relationship (person_id, relationship_id) VALUES
    (1, 2),
    (1, 3);

INSERT INTO rel_attribute_person (person_id, name, value) VALUES
    (1, 'Téléphone', '0212345678'),
    (1, 'Email', 'yay@example.com'),
    (1, NULL, 'apporter du lait');


-- Query: List persons and the primary relationship that we are entertaining with them
-- derrière chacune des 2 requêtes suivantes, le moteur fait exactement la même chose.
SELECT * FROM person, relationship WHERE person.relationship_id = relationship.id;

SELECT * FROM person
    JOIN relationship ON relationship.id = person.relationship_id;

-- Note: La preuve que les requêtes avec JOIN ou WHERE ci-dessus sont identiques:
-- En fait, lorsqu'il traite la requête, il commence par transformer les clauses JOIN
-- pour en faire des clauses WHERE !
EXPLAIN SELECT * FROM person, relationship WHERE person.relationship_id = relationship.id;

EXPLAIN SELECT * FROM person
    JOIN relationship ON relationship.id = person.relationship_id;

-- -- Query: List persons and the secondary relationships that we are entertaining with them
-- SELECT * FROM person, relationship, rel_secondary_relationship
-- WHERE
--     rel_secondary_relationship.person_id = person.id
--     AND rel_secondary_relationship.relationship_id = relationship.id;

-- SELECT * FROM person
--     JOIN rel_secondary_relationship ON rel_secondary_relationship.person_id = person.id
--     JOIN relationship ON relationship.id = rel_secondary_relationship.relationship_id;
--     -- JOIN relationship AS relationship_secondary ON relationship_secondary.id = rel_secondary_relationship.relationship_id;

-- -- Query: List persons, primary and secondary relationship at once
-- SELECT * FROM person
--     JOIN relationship AS relationship_primary ON relationship_primary.id = person.relationship_id
--     JOIN rel_secondary_relationship ON rel_secondary_relationship.person_id = person.id
--     JOIN relationship AS relationship_secondary ON relationship_secondary.id = rel_secondary_relationship.relationship_id;
