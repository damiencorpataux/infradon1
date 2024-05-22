from flask import Flask, request, jsonify, send_from_directory
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.exc import SQLAlchemyError
import os
import urllib.parse

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://postgres:postgres@localhost/micromessenger'  # Adjust as needed
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False


db = SQLAlchemy(app)

class Contact(db.Model):
    __tablename__ = 'contact'
    id = db.Column(db.Integer, primary_key=True)
    status_id = db.Column(db.Integer)
    name = db.Column(db.String)

class Message(db.Model):
    __tablename__ = 'rel_message'
    id = db.Column(db.Integer, primary_key=True)
    #creation = db.Column(db.DateTime)  # let postgres use its default value.
    content = db.Column(db.String)
    contact_id_source = db.Column(db.Integer)
    contact_id_destination = db.Column(db.Integer)

class ViewContact(db.Model):
    __tablename__ = 'view_contacts'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String)
    status_id = db.Column(db.Integer)

    def as_dict(self):
        return {c.name: getattr(self, c.name) for c in self.__table__.columns}

class ViewMessage(db.Model):
    __tablename__ = 'view_messages'
    id = db.Column(db.Integer, primary_key=True)
    creation = db.Column(db.DateTime)
    content = db.Column(db.String)
    contact_source_id = db.Column(db.Integer)
    contact_destination_id = db.Column(db.Integer)
    contact_source_name = db.Column(db.String)
    contact_destination_name = db.Column(db.String)

    def as_dict(self):
        return {c.name: getattr(self, c.name) for c in self.__table__.columns}


@app.route('/')
def index():
    return send_from_directory(os.path.dirname(os.path.abspath(__file__)), 'view.html')

@app.route('/api/contacts', methods=['GET'])
def get_contacts():
    try:
        contacts = ViewContact.query.all()
        return jsonify([contact.as_dict() for contact in contacts])
    except SQLAlchemyError as e:
        return str(e), 500

@app.route('/api/messages', methods=['GET'])
def get_messages():
    try:
        messages = ViewMessage.query.order_by(ViewMessage.creation.asc()).all()
        return jsonify([message.as_dict() for message in messages])
    except SQLAlchemyError as e:
        return str(e), 500

@app.route('/api/messages/<int:source>/<int:destination>/<message>', methods=['POST'])
def post_message(source, destination, message):
    try:
        decoded_message = urllib.parse.unquote(message)
        new_message = Message(contact_id_source=source, contact_id_destination=destination, content=decoded_message)
        db.session.add(new_message)
        db.session.commit()
        return 'Message added', 200
    except SQLAlchemyError as e:
        return str(e), 500

@app.route('/api/contacts/<contact_name>', methods=['POST'])
def post_contact(contact_name):
    try:
        decoded_contact_name = urllib.parse.unquote(contact_name)
        new_contact = Contact(status_id=1, name=decoded_contact_name)
        db.session.add(new_contact)
        db.session.commit()
        return 'Contact added', 200
    except SQLAlchemyError as e:
        return str(e), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
