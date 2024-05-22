micromessenger
=

A µicroscopic messaging system.

Installation
-
Setup the database:
```sh
psql --username postgres --command "CREATE DATABASE micromessenger"
psql s--username postgres --file "model.sql"
```

Install the backend:
```sh
python3 -m venv venv
. venv/bin/activate
pip install -r requirements.txt
```

Usage
-
Start the backend server (HTTP):
```sh
. venv/bin/activate
python3 controller.py
```

Then, open a browser to http://localhost:8080.
