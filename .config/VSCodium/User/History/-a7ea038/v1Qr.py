from flask import Flask, render_template, request, jsonify, send_file
import pollinations as ai
import json
import os
from datetime import datetime
import uuid

app = Flask(__name__)

# In-memory storage for conversations (in production, use a database)
conversations = {}
current_conversation = None

# Available models - mapping to actual Pollinations model names
MODELS = {
    "mistral": "mistralai/Mistral-7B-Instruct-v0.2",
    "openai": "gpt-3.5-turbo",
    "openai-large": "gpt-4",
    "llama": "meta-llama/Llama-2-70b-chat-hf",
    "llama3": "meta-llama/Meta-Llama-3-70B-Instruct",
    "gemini": "gemini-pro",
    "claude": "claude-3-haiku"
}

@app.route('/')
def index():
    return render_template('index.html', models=MODELS)

@app.route('/api/chat', methods=['POST'])
def chat():
    global current_conversation
    
    data = request.json
    message = data.get('message')
    model = data.get('model', 'mistral')
    ai_role = data.get('ai_role', 'You are a helpful AI assistant')
    message_type = data.get('type', 'text')  # 'text' or 'image'
    
    if not message:
        return jsonify({'error': 'Message is required'}), 400
    
    if not current_conversation:
        current_conversation = str(uuid.uuid4())
        conversations[current_conversation] = {
            'id': current_conversation,
            'title': message[:30] + '...' if len(message) > 30 else message,
            'messages': [],
            'created_at': datetime.now().isoformat()
        }
    
    # Add user message
    user_message = {
        'id': str(uuid.uuid4()),
        'role': 'user',
        'content': message,
        'type': 'text',
        'timestamp': datetime.now().isoformat()
    }
    conversations[current_conversation]['messages'].append(user_message)
    
    if message_type == 'image':
        # Generate image using Pollinations
        try:
            # For image generation, use the image generation method
            image_url = ai.generate(message, model="dall-e-3")  # Note: correct model name
            ai_response = {
                'id': str(uuid.uuid4()),
                'role': 'assistant',
                'content': image_url,
                'type': 'image',
                'timestamp': datetime.now().isoformat()
            }
        except Exception as e:
            ai_response = {
                'id': str(uuid.uuid4()),
                'role': 'assistant',
                'content': f"Error generating image: {str(e)}",
                'type': 'text',
                'timestamp': datetime.now().isoformat()
            }
    else:
        # Generate text response
        try:
            # Prepare messages for chat
            chat_messages = []
            
            # Add system message if provided
            if ai_role:
                chat_messages.append({"role": "system", "content": ai_role})
            
            # Add conversation history
            for msg in conversations[current_conversation]['messages'][:-1]:  # Exclude the last user message
                if msg['type'] == 'text':
                    chat_messages.append({"role": msg['role'], "content": msg['content']})
            
            # Add current user message
            chat_messages.append({"role": "user", "content": message})
            
            # Get the actual model name
            model_name = MODELS.get(model, 'mistralai/Mistral-7B-Instruct-v0.2')
            
            # Generate response using Pollinations chat
            response = ai.chat(chat_messages, model=model_name)
            ai_response = {
                'id': str(uuid.uuid4()),
                'role': 'assistant',
                'content': response,
                'type': 'text',
                'timestamp': datetime.now().isoformat()
            }
        except Exception as e:
            ai_response = {
                'id': str(uuid.uuid4()),
                'role': 'assistant',
                'content': f"Error: {str(e)}",
                'type': 'text',
                'timestamp': datetime.now().isoformat()
            }
    
    conversations[current_conversation]['messages'].append(ai_response)
    
    return jsonify({
        'conversation_id': current_conversation,
        'message': ai_response
    })

@app.route('/api/conversations')
def get_conversations():
    conv_list = list(conversations.values())
    conv_list.sort(key=lambda x: x['created_at'], reverse=True)
    return jsonify(conv_list)

@app.route('/api/conversation/<conv_id>')
def get_conversation(conv_id):
    if conv_id in conversations:
        return jsonify(conversations[conv_id])
    return jsonify({'error': 'Conversation not found'}), 404

@app.route('/api/new-conversation', methods=['POST'])
def new_conversation():
    global current_conversation
    current_conversation = str(uuid.uuid4())
    return jsonify({'status': 'success', 'conversation_id': current_conversation})

@app.route('/api/download-conversation/<conv_id>')
def download_conversation(conv_id):
    if conv_id not in conversations:
        return jsonify({'error': 'Conversation not found'}), 404
    
    conv = conversations[conv_id]
    filename = f"conversation_{conv_id}.json"
    
    with open(filename, 'w') as f:
        json.dump(conv, f, indent=2)
    
    def remove_file(response):
        try:
            os.remove(filename)
        except:
            pass
        return response
    
    return send_file(filename, as_attachment=True, download_name=filename)

if __name__ == '__main__':
    app.run(debug=True)