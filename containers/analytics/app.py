import os
from flask import Flask, request
from pymongo import MongoClient

app = Flask(__name__)
MONGODB_URI = os.getenv("MONGODB_URI")
client = MongoClient(MONGODB_URI)  # MongoDB connection string
db = client['requests']  # MongoDB database name
collection = db['requests']  # MongoDB collection name

@app.route('/', defaults={'path': ''}, methods=['GET', 'POST'])
@app.route('/<path:path>', methods=['GET', 'POST'])
def catch_all(path):
    # Get the request data
    data = request.data

    # Get the request endpoint
    endpoint = request.path

    # Get the request origin
    origin = request.headers.get('Origin')

    # Store the request data, endpoint, and origin in MongoDB
    request_info = {
        'endpoint': endpoint,
        'data': data.decode('utf-8'),  # Decode data from bytes to string
        'origin': origin
    }
    collection.insert_one(request_info)

    # Return a response
    response = {
        'message': 'Request data, endpoint, and origin stored in MongoDB',
        'endpoint': endpoint,
        'data': data.decode('utf-8'),
        'origin': origin
    }

    return response

if __name__ == '__main__':
    app.run()
