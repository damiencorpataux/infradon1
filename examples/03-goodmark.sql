--
-- goodmark.com - store and project your marks !
--

-- Structure: Database (dev purpose)
\connect postgres
DROP DATABASE goodmark;
CREATE DATABASE goodmark;
\connect goodmark


-- Structure: Tables
CREATE TABLE weight_unit (
    id SERIAL PRIMARY KEY,
    symbol TEXT NOT NULL,
    name TEXT NOT NULL
);

CREATE TABLE module (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    ects INTEGER
    -- period_id INTEGER  -- FIXME: Shall we relate period to `module` or `mark` ?
);

CREATE TABLE unit (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    module_id INTEGER REFERENCES module(id)
);

CREATE TABLE period (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE mark (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    value NUMERIC NOT NULL,
    weight NUMERIC,
    weight_unit_id INTEGER REFERENCES weight_unit(id),
    period_id INTEGER REFERENCES period(id),  -- FIXME: Shall we relate period to `module` or `mark` ?
    module_id INTEGER REFERENCES module(id)
);


-- Data: Catalogs
INSERT INTO weight_unit (symbol, name) VALUES
    ('%', 'Percent (eg. 10%)'),
    ('*', 'Factor (eg. counts for 2 or 0.5)'),
    ('+', 'Addition (eg. 0.5 bonus)');

INSERT INTO period (name) VALUES
    ('Default');

INSERT INTO module (name) VALUES
    ('Default');

INSERT INTO unit (name, module_id) VALUES
    ('Default', 1);


-- Data: Sample (dev purpose)
INSERT INTO period (name) VALUES
    ('2024, 1er semstre');

INSERT INTO module (name) VALUES
    ('Technologies de l''information');

INSERT INTO unit (name, module_id) VALUES
    ('Infrastructures de données', 2);

INSERT INTO mark (name, value, weight, weight_unit_id, period_id, module_id) VALUES
    ('Test 1', 5.4, 0.5, 2, 2, 2),
    ('Test 2', 4.8, 0.5, 2, 2, 2),
    ('Bonus', 0.4, NULL, 3, 2, 2);


-- TODO: CREATE VIEW permettant le calcul de la moyenne totale et par module.
-- View: All marks with all joins
CREATE VIEW view_marks AS
    SELECT
        mark.id AS mark_id,
        period.id AS period_id,
        module.id AS module_id,
        unit.id AS unit_id,
        period.name AS period_name,
        module.name AS module_name,
        unit.name AS unit_name,
        weight_unit.name AS weight_unit_name,
        weight_unit.symbol AS weight_unit_symbol,
        mark.weight AS mark_weight,
        mark.value AS mark_value,
        mark.name AS mark_name
    FROM mark
        JOIN period ON period.id = mark.period_id
        JOIN module ON module.id = mark.module_id
        JOIN unit ON unit.module_id = module.id
        JOIN weight_unit ON weight_unit.id = mark.weight_unit_id;

-- View: All marks with less coulumns
CREATE VIEW view_marks_short AS
    SELECT mark_id, period_name, module_name, unit_name, mark_weight, weight_unit_symbol, mark_value, mark_name
    FROM view_marks;

-- Notes:
-- -- Query: Export to  (Excel)
-- -- depuis la CLI Linux:
-- --   psql -U postgres goodmark --csv -c "SELECT * FROM view_marks"
-- \pset format csv
-- SELECT * FROM view_marks_short;
-- \pset format aligned

-- -- Query: JSON Output
-- WITH query AS
-- (
--     SELECT * FROM view_marks
-- )
-- SELECT json_agg(row_to_json(query)) FROM query;


-- TODO: Try to implement weighted average using SUM and CASE, as described here:
-- https://stackoverflow.com/a/36652407/1300775
SELECT mark_id, module_id, mark_weight, weight_unit_symbol, mark_value, mark_name FROM view_marks;

SELECT  -- FIXME: Basic average that doesn't take weight_unit into acount
    module_id,
    count(*),
    AVG(
        mark_value
    ) AS mark_count
FROM view_marks
GROUP BY module_id;

SELECT  -- FIXME: I don't understant this behaviour.
    module_id,
    count(*),
    SUM(mark_value) FILTER (WHERE weight_unit_symbol = '+')
    + AVG(mark_value) FILTER (WHERE weight_unit_symbol = '*')  -- FIXME: Take weight into account
    + AVG(mark_value / 100) FILTER (WHERE weight_unit_symbol = '%')  -- FIXME: Same
    AS mark_module
FROM view_marks
-- WHERE mark_id < 3  -- FIXME: This fails
GROUP BY module_id;


-- FIXME: TODO: Weighted average for a module, see:
-- https://stackoverflow.com/a/71866616/1300775
-- https://stackoverflow.com/a/8924119/1300775
-- and chatgpt: https://chat.openai.com/share/23b5a19a-4f14-4977-8792-5dd1ef71b3b4
CREATE OR REPLACE FUNCTION weighted_average_state(
    numeric, -- running total
    numeric, -- mark_value
    numeric, -- weight
    text     -- weight_unit_symbol
) RETURNS numeric AS $$
BEGIN
    -- TODO: Should: When weight_unit_symbol = NULL, then compute the natural average (mark_value/number_of_marks)
    IF $4 = '+' THEN
        RETURN $1 + $2; -- Add mark_value to the running total
    ELSIF $4 = '*' THEN
        RETURN $1 + $2 * $3; -- Multiply mark_value by weight and add to the running total
    ELSIF $4 = '%' THEN
        RETURN $1 + $2 / 100 * $3; -- Calculate percentage of mark_value, multiply by weight, and add to the running total
    ELSE
        RETURN $1; -- If weight_unit_symbol is not recognized, return the running total unchanged
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION weighted_average_final(numeric) RETURNS numeric AS $$
BEGIN
    RETURN $1; -- Return the running total for sum: the weight is already computed
END;
$$ LANGUAGE plpgsql;

CREATE AGGREGATE weighted_average(numeric, numeric, text) (
    sfunc = weighted_average_state,
    stype = numeric,
    finalfunc = weighted_average_final,
    initcond = '0' -- Initial value for the running total
);

SELECT mark_id, module_id, mark_weight, weight_unit_symbol, mark_value, mark_name FROM view_marks;
SELECT module_id, count(*), avg(mark_value) AS mark_count FROM view_marks GROUP BY module_id;
SELECT module_id, count(*), weighted_average(mark_value, mark_weight, weight_unit_symbol) FROM view_marks WHERE mark_id < 3 GROUP BY module_id;
