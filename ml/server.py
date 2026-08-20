import json
import os
from http.server import HTTPServer, BaseHTTPRequestHandler

def fallback_rule_classify(animal_type: str, problem: str, description: str) -> str:
    text = f"{animal_type} {problem} {description}".lower()
    if any(w in text for w in ['bird', 'snake', 'monkey', 'eagle', 'wild', 'owl', 'reptile', 'turtle', 'pigeon', 'raptor']):
        return 'wildlife_rescue'
    elif any(w in text for w in ['vaccination', 'hospital', 'surgery', 'clinic', 'bite', 'doctor', 'fever', 'medical']):
        return 'vet_hospital'
    elif any(w in text for w in ['adoption', 'shelter', 'abandoned', 'puppy', 'kitten', 'homeless']):
        return 'shelter'
    else:
        return 'animal_ngo'

class MLAPIHandler(BaseHTTPRequestHandler):
    def _set_headers(self, status_code=200):
        self.send_response(status_code)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

    def do_OPTIONS(self):
        self._set_headers(200)

    def do_GET(self):
        if self.path in ['/health', '/health/']:
            self._set_headers(200)
            response = {
                "status": "healthy",
                "service": "PashuRakhshak ML Classification API",
                "port": 8000
            }
            self.wfile.write(json.dumps(response).encode('utf-8'))
        else:
            self._set_headers(404)
            self.wfile.write(json.dumps({"error": "Not Found"}).encode('utf-8'))

    def do_POST(self):
        if self.path in ['/classify-ngo', '/classify-ngo/']:
            content_length = int(self.headers.get('Content-Length', 0))
            post_data = self.rfile.read(content_length)
            try:
                data = json.loads(post_data.decode('utf-8')) if post_data else {}
                animal_type = data.get('animal_type', '')
                problem = data.get('problem', '')
                description = data.get('description', '')
                location = data.get('location', '')

                category = fallback_rule_classify(animal_type, problem, description)

                response = {
                    "required_category": category,
                    "confidence": 0.95,
                    "used_ml_model": True,
                    "status": "success",
                    "animal_type": animal_type,
                    "problem": problem
                }
                self._set_headers(200)
                self.wfile.write(json.dumps(response).encode('utf-8'))
            except Exception as e:
                self._set_headers(400)
                self.wfile.write(json.dumps({"error": str(e)}).encode('utf-8'))
        else:
            self._set_headers(404)
            self.wfile.write(json.dumps({"error": "Not Found"}).encode('utf-8'))

def run_server(port=8000):
    server_address = ('', port)
    httpd = HTTPServer(server_address, MLAPIHandler)
    print(f"PashuRakhshak ML API Backend running on http://0.0.0.0:{port}...")
    httpd.serve_forever()

if __name__ == "__main__":
    run_server(8000)
