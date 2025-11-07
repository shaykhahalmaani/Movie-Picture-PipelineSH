from flask import Flask, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Sample movie data
movies_data = [
    {"id": "123", "title": "Top Gun: Maverick"},
    {"id": "456", "title": "Sonic the Hedgehog"},
    {"id": "789", "title": "A Quiet Place"}
]

@app.route('/movies', methods=['GET'])
def get_movies():
    """Return list of movies"""
    return jsonify({"movies": movies_data})

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({"status": "healthy"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)

