from flask import request, jsonify
from app import app
from app.api import get_db_connection
import json

@app.route('/api/send_req', methods=['POST', 'GET'])
def api_method():
    data = request.get_json()
    
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute('SELECT public.test_api(%s)', (json.dumps(data), ))
            res = cur.fetchone()[0]
        
    print(res)
    return jsonify({'data': res}), 201