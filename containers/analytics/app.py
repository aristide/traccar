from flask import Flask, request, jsonify
from db import app, db, RequestLog

@app.route('/', defaults={'path': ''}, methods=['GET', 'POST'])
@app.route('/<path:path>', methods=['GET', 'POST'])
def catch_all(path):
    data = request.data
    endpoint = request.path

    new_request = RequestLog(endpoint=endpoint, request_data=data)
    db.session.add(new_request)
    db.session.commit()

    response = {
        'message': 'Request logged successfully',
        'endpoint': endpoint
    }

    return jsonify(response)

if __name__ == '__main__':
    app.run()