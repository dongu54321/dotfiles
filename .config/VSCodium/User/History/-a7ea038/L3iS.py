from flask import Flask, jsonify, send_from_directory, request
import requests

app = Flask(__name__, static_folder='../frontend/build', static_url_path='/')

@app.route('/api/text/<prompt>', methods=['GET'])
def generate_text(prompt):
    response = requests.get(f'https://text.pollinations.ai/{prompt}')
    return jsonify(response.json())

@app.route('/api/image/<prompt>', methods=['GET'])
def generate_image(prompt):
    response = requests.get(f'https://image.pollinations.ai/prompt/{prompt}')
    return jsonify(response.json())

@app.route('/api/models/text', methods=['GET'])
def get_text_models():
    response = requests.get('https://text.pollinations.ai/models')
    return jsonify(response.json())

@app.route('/api/models/image', methods=['GET'])
def get_image_models():
    response = requests.get('https://image.pollinations.ai/models')
    return jsonify(response.json())

@app.route('/', defaults={'path': ''})
@app.route('/<path:path>')
def serve(path):
    if path != "" and os.path.exists(app.static_folder + '/' + path):
        return send_from_directory(app.static_folder, path)
    else:
        return send_from_directory(app.static_folder, 'index.html')

if __name__ == '__main__':
    app.run(debug=True)