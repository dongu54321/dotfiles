from flask import Flask, render_template, request, jsonify, send_file
import requests
import json
import os
from datetime import datetime
from flask_wtf.csrf import CSRFProtect

app = Flask(__name__)
csrf = CSRFProtect(app)
# In-memory storage for conversations (in production, use database)
conversations = {}
current_conversation_id = None

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/models/text')
def get_text_models():
    try:
        response = requests.get('https://text.pollinations.ai/models')
        response.raise_for_status()  # Raises an error for bad status codes
        data = response.json()

        # Extract 'name' from each model dictionary
        model_names = [model["name"] for model in data if "name" in model]
        return model_names

    except requests.exceptions.RequestException as e:
        print(f"Error fetching data: {e}")
        return []
    except ValueError as e:
        print(f"Error parsing JSON: {e}")
        return []

@app.route('/api/models/image')
def get_image_models():
    try:
        response = requests.get('https://image.pollinations.ai/models')
        return jsonify(response.json())
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/chat/text', methods=['POST'])
def chat_text():
    data = request.json
    prompt = data.get('prompt', '')
    model = data.get('model', '')
    role = data.get('role', 'helpful assistant')
    
    try:
        # Format the prompt with role
        full_prompt = f"You are a {role}. {prompt}"
        
        url = f'https://text.pollinations.ai/{prompt}'
        if model:
            url += f'?model={model}'
            
        response = requests.get(url)
        return jsonify({'response': response.text})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/chat/image', methods=['POST'])
def chat_image():
    data = request.json
    prompt = data.get('prompt', '')
    model = data.get('model', '')

    try:
        url = f'https://image.pollinations.ai/prompt/{prompt}'
        if model:
            url += f'?model={model}'
            
        response = requests.get(url)
        image_url = response.url if response.status_code == 200 else None
        
        return jsonify({'image_url': image_url})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# @app.route('/api/conversations', methods=['GET'])
# def get_conversations():
#     return jsonify(list(conversations.values()))

# @app.route('/api/conversations', methods=['POST'])
# def create_conversation():
#     global current_conversation_id
#     conversation_id = datetime.now().strftime('%Y%m%d%H%M%S')
#     title = request.json.get('title', f'Chat {conversation_id}')
    
#     conversation = {
#         'id': conversation_id,
#         'title': title,
#         'messages': [],
#         'created_at': datetime.now().isoformat()
#     }
    
#     conversations[conversation_id] = conversation
#     current_conversation_id = conversation_id
    
#     return jsonify(conversation)

# @app.route('/api/conversations/<conversation_id>', methods=['GET'])
# def get_conversation(conversation_id):
#     if conversation_id in conversations:
#         return jsonify(conversations[conversation_id])
#     return jsonify({'error': 'Conversation not found'}), 404

# @app.route('/api/conversations/<conversation_id>/messages', methods=['POST'])
# def add_message(conversation_id):
#     if conversation_id not in conversations:
#         return jsonify({'error': 'Conversation not found'}), 404
        
#     message = request.json
#     conversations[conversation_id]['messages'].append(message)
#     return jsonify({'success': True})

# @app.route('/api/conversations/<conversation_id>/download')
# def download_conversation(conversation_id):
#     if conversation_id not in conversations:
#         return jsonify({'error': 'Conversation not found'}), 404
        
#     conversation = conversations[conversation_id]
#     filename = f"conversation_{conversation_id}.txt"
    
#     content = f"Conversation: {conversation['title']}\n"
#     content += f"Created: {conversation['created_at']}\n"
#     content += "=" * 50 + "\n\n"
    
#     for msg in conversation['messages']:
#         content += f"{msg['sender']}: {msg['content']}\n"
#         if 'image_url' in msg:
#             content += f"Image: {msg['image_url']}\n"
#         content += "\n"
    
#     with open(filename, 'w', encoding='utf-8') as f:
#         f.write(content)
    
#     return send_file(filename, as_attachment=True)

if __name__ == '__main__':
    app.run(debug=True)
