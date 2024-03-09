--
-- goodgrade.com - Good Grade stores and projects your Grades !
--

-- Structure: Database (dev purpose)
\connect postgres
DROP DATABASE goodgrade;
CREATE DATABASE goodgrade;
\connect goodgrade


-- Structure: Tables
CREATE TABLE grade_weight (
    id SERIAL PRIMARY KEY,
    symbol TEXT NOT NULL,
    name TEXT NOT NULL
);

CREATE TABLE module (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    ects INTEGER
    -- period_id INTEGER  -- FIXME: Shall we relate period to `module` or `grade` ?
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

CREATE TABLE grade (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    value NUMERIC NOT NULL,
    weight NUMERIC,
    grade_weight_id INTEGER REFERENCES grade_weight(id),
    period_id INTEGER REFERENCES period(id),  -- FIXME: Shall we relate period to `module` or `grade` ?
    module_id INTEGER REFERENCES module(id)
);


-- Data: Catalogs
INSERT INTO grade_weight (symbol, name) VALUES
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
    ('2024, 1er semestre');

INSERT INTO module (name, ects) VALUES
    ('Technologies de l''information', 5);

INSERT INTO unit (name, module_id) VALUES
    ('Infrastructures de données 1', 2);

INSERT INTO grade (name, value, weight, grade_weight_id, period_id, module_id) VALUES
    ('Test 1', 5.4, 0.5, 2, 2, 2),
    ('Test 2', 4.8, 0.5, 2, 2, 2),
    ('Bonus', 0.4, NULL, 3, 2, 2);


-- TODO: CREATE VIEW permettant le calcul de la moyenne totale et par module.
-- View: All grades with all joins
CREATE VIEW view_grades AS
    SELECT
        grade.id AS grade_id,
        period.id AS period_id,
        module.id AS module_id,
        unit.id AS unit_id,
        period.name AS period_name,
        module.name AS module_name,
        module.ects AS module_ects,
        unit.name AS unit_name,
        grade_weight.name AS grade_weight_name,
        grade_weight.symbol AS grade_weight_symbol,
        CONCAT(grade.weight, grade_weight.symbol, grade.value) AS grade_weight_full,
        grade.weight AS grade_weight,
        grade.value AS grade_value,
        grade.name AS grade_name
    FROM grade
        JOIN period ON period.id = grade.period_id
        JOIN module ON module.id = grade.module_id
        JOIN unit ON unit.module_id = module.id
        JOIN grade_weight ON grade_weight.id = grade.grade_weight_id;

-- View: All grades with less coulumns
CREATE VIEW view_grades_short AS
    SELECT grade_id, period_name, module_name, unit_name, grade_weight, grade_weight_symbol, grade_value, grade_name
    FROM view_grades;

-- Notes:
-- -- Query: Export to  (Excel)
-- -- depuis la CLI Linux:
-- --   psql -U postgres goodgrade --csv -c "SELECT * FROM view_grades"
-- \pset format csv
-- SELECT * FROM view_grades_short;
-- \pset format aligned

-- -- Query: JSON Output
-- -- https://stackoverflow.com/q/24006291/1300775
-- WITH query AS
-- (
--     SELECT * FROM view_grades
-- )
-- SELECT json_agg(row_to_json(query)) FROM query;


-- TODO: Try to implement weighted average using SUM and CASE, as described here:
-- https://stackoverflow.com/a/36652407/1300775
SELECT grade_id, module_id, grade_weight, grade_weight_symbol, grade_value, grade_name FROM view_grades;

SELECT  -- FIXME: Basic average that doesn't take grade_weight into acount
    module_id,
    COUNT(*),
    AVG(
        grade_value
    ) AS grade_count
FROM view_grades
GROUP BY module_id;

SELECT  -- FIXME: I don't understant this behaviour.
    module_id,
    COUNT(*),
    SUM(grade_value) FILTER (WHERE grade_weight_symbol = '+')
    + AVG(grade_value) FILTER (WHERE grade_weight_symbol = '*')  -- FIXME: Take weight into account
    + AVG(grade_value / 100) FILTER (WHERE grade_weight_symbol = '%')  -- FIXME: Same
    AS grade_module
FROM view_grades
-- WHERE grade_id < 3  -- FIXME: This fails
GROUP BY module_id;


-- FIXME: TODO: Weighted average for a module, see:
-- https://stackoverflow.com/a/71866616/1300775
-- https://stackoverflow.com/a/8924119/1300775
-- and chatgpt: https://chat.openai.com/share/23b5a19a-4f14-4977-8792-5dd1ef71b3b4
CREATE OR REPLACE FUNCTION weighted_average_state(
    numeric, -- running total
    numeric, -- grade_value
    numeric, -- weight
    text     -- grade_weight_symbol
) RETURNS numeric AS $$
BEGIN
    -- TODO: Should: When grade_weight_symbol = NULL, then compute the natural average (grade_value/number_of_grades)
    IF $4 = '+' THEN
        RETURN $1 + $2; -- Add grade_value to the running total
    ELSIF $4 = '*' THEN
        RETURN $1 + $2 * $3; -- Multiply grade_value by weight and add to the running total
    ELSIF $4 = '%' THEN
        RETURN $1 + $2 / 100 * $3; -- Calculate percentage of grade_value, multiply by weight, and add to the running total
    ELSE
        RETURN $1; -- If grade_weight_symbol is not recognized, return the running total unchanged
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

CREATE VIEW view_grades_avg_per_module AS
    SELECT
        period_id,
        module_id,
        unit_id,
        period_name,
        module_name,
        module_ects,
        STRING_AGG(CONCAT(grade_weight, grade_weight_symbol, grade_value) , ' + ') AS grade_weights_full,
        STRING_AGG(DISTINCT unit_name, ', ') AS unit_names,
        COUNT(*) AS grade_count,
        weighted_average(grade_value, grade_weight, grade_weight_symbol) AS grade_average
    FROM view_grades
    GROUP BY
        period_id,
        module_id,
        unit_id,
        period_name,
        module_name,
        module_ects;


-- Query: For testing
SELECT * FROM view_grades_avg_per_module;
-- FIXME: Plain average, missing weights
-- SELECT period_id, module_id, unit_id, period_name, module_name, unit_name, COUNT(*) AS grade_count, AVG(grade_value) AS grade_average FROM view_grades GROUP BY module_id, module_name;
