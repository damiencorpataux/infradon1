#!/bin/bash

USERS=$(find /home -maxdepth 1 -type d -regex '/home/[a-z]+\.[a-z]+' | sed s'|/home/||')
HOST=localhost

echo Populating $USERS

for USER in $USERS
do
    echo "Creating database $USER -> Postgres @ $HOST"
    STATEMENT="CREATE DATABASE \"$USER\" WITH ENCODING = 'UTF8'"
    psql -U postgres -h $HOST -c "$STATEMENT"  || true  # prevent script from exiting if database already exists

    echo "Creating role $USER -> Postgres @ $HOST"
    PASS=infradon1${USER}
    STATEMENT="CREATE ROLE \"$USER\" LOGIN PASSWORD '$PASS'"
    psql -U postgres -h $HOST -c "$STATEMENT"  || true  # prevent script from exiting if user already exists

    echo "Granting rights to $USER -> Postgres @ $HOST"
    STATEMENT="GRANT ALL PRIVILEGES ON DATABASE \"$USER\" TO \"$USER\""
    psql -U postgres -h $HOST -c "$STATEMENT"

    echo "Done."
    echo
done
