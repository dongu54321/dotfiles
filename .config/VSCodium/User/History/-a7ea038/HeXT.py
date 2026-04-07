from flask import Flask, jsonify, request
from flask_cors import CORS
import requests

app = Flask(__name__)
CORS(app)

# In-memory storage for chats
chats =   @app.route('/api/chats', methods=['GET', 'POST'])
def chat_list_create():
    if request.method == 'POST':
        data = request.get_json()
        chat = {
            'id': len(chats) + ,
            'role': data.get('role', 'assistant'),
            'conversation':           }
        chats.append(chat)
        return jsonify(chat), 
    else:
        return jsonify(chats)

@app.route('/api/chats/<int:chat_id>', methods=['GET', 'PUT', 'DELETE'])
def chat_detail(chat_id):
    chat = next((c for c in chats if c['id'] == chat_id), None)
    if not chat:
        return jsonify({'error': 'Chat not found'}), 

    if request.method == 'GET':
        return jsonify(chat)
    elif request.method == 'PUT':
        data = request.get_json()
        chat['role'] = data.get('role', chat['role'])
        chat['conversation'] = data.get('conversation', chat['conversation'])
        return jsonify(chat)
    elif request.method == 'DELETE':
        chats.remove(chat)
        return jsonify({'message': 'Chat deleted'})

@app.route('/api/generate/text', methods=['POST'])
def generate_text():
    data = request.get_json()
    prompt = data.get('prompt', '')
    model = data.get('model', 'default-text-model')
    response = requests.get(f'https://text.pollinations.ai/{model}/{prompt}')
    if response.status_code == :
        return jsonify(response.json())
    return jsonify({'error': 'Failed to generate text'}), 

@app.route('/api/generate/image', methods=['POST'])
def generate_image():
    data = request.get_json()
    prompt = data.get('prompt', '')
    model = data.get('model', 'default-image-model')
    response = requests.get(f'https://image.pollinations.ai/prompt/{model}/{prompt}')
    if response.status_code == :
        return jsonify(response.json())
    return jsonify({'error': 'Failed to generate image'}), 

if __name__ == '__main__':
    app.run(debug=True)