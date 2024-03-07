\connect postgres
DROP DATABASE contacts;

CREATE DATABASE contacts;
\connect contacts


-- Structure
CREATE TABLE relationship (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE person (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    relationship_id INTEGER NOT NULL,
    CONSTRAINT fk_relationship_id FOREIGN KEY(relationship_id) REFERENCES relationship(id)
);

CREATE TABLE rel_secondaryrelationships (
    id SERIAL PRIMARY KEY,
    person_id INTEGER NOT NULL,
    relationship_id INTEGER NOT NULL,
    CONSTRAINT fk_person_id FOREIGN KEY(person_id) REFERENCES person(id),
    CONSTRAINT fk_relationship_id FOREIGN KEY(relationship_id) REFERENCES relationship(id)
);


-- Sample data
INSERT INTO relationship (name) VALUES
    ('Unknown'),
    ('Family'),
    ('Friend');

INSERT INTO person (name, relationship_id) VALUES ('Toto', 1);


-- Queries
SELECT * FROM person, relationship WHERE person.relationship_id = relationship.id;

SELECT * FROM person
    JOIN relationship ON person.relationship_id = relationship.id;


INSERT INTO rel_secondaryrelationships (person_id, relationship_id) VALUES
    (1, 2),
    (1, 3);

SELECT * FROM person, relationship, rel_secondaryrelationships
WHERE
    rel_secondaryrelationships.person_id = person.id
    AND rel_secondaryrelationships.relationship_id = relationship.id;

SELECT * FROM rel_secondaryrelationships
    JOIN person ON rel_secondaryrelationships.person_id = person.id
    JOIN relationship ON rel_secondaryrelationships.relationship_id = relationship.id;
