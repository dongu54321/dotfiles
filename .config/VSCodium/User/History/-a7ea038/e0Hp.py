from flask import Flask, render_template, request, jsonify
import requests
import json

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/chat', methods=['POST'])
def chat():
    data = request.json
    message = data.get('message')
    model = data.get('model', 'mistral')
    role = data.get('role', 'helpful assistant')
    
    # Text generation
    text_response = requests.post(
        "https://text.pollinations.ai/",
        json={
            "messages": [
                {"role": "system", "content": f"You are a {role}."},
                {"role": "user", "content": message}
            ],
            "model": model
        }
    )
    
    return jsonify({"text": text_response.text})

@app.route('/image', methods=['POST'])
def generate_image():
    data = request.json
    prompt = data.get('prompt')
    
    # Image generation
    image_response = requests.post(
        "https://image.pollinations.ai/prompt/" + prompt
    )
    
    return jsonify({"image_url": image_response.url})

if __name__ == '__main__':
    app.run(debug=True)