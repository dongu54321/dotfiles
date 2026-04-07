// static/script.js
document.addEventListener('DOMContentLoaded', () => {
    const chatHistory = document.getElementById('chat-history');
    const userInput = document.getElementById('user-input');
    const sendBtn = document.getElementById('send-btn');
    const modelSelect = document.getElementById('model-select');
    const roleSelect = document.getElementById('role-select');
    const textTab = document.getElementById('text-tab');
    const imageTab = document.getElementById('image-tab');
    const modeText = document.getElementById('mode-text');
    const downloadBtn = document.getElementById('download-btn');
    const newChatBtn = document.getElementById('new-chat-btn');
    const chatList = document.getElementById('chat-list');
    
    let currentMode = 'text';
    let conversations = JSON.parse(localStorage.getItem('conversations')) || {};
    let currentConversationId = localStorage.getItem('currentConversationId') || null;
    
    // Initialize conversations
    if (Object.keys(conversations).length === 0) {
        createNewConversation();
    } else if (!currentConversationId || !conversations[currentConversationId]) {
        // Set to first conversation if current doesn't exist
        currentConversationId = Object.keys(conversations)[0];
    }
    
    // Load conversation from localStorage
    renderConversation();
    renderChatList();
    
    // Tab switching
    textTab.addEventListener('click', () => switchMode('text'));
    imageTab.addEventListener('click', () => switchMode('image'));
    
    // New chat button
    newChatBtn.addEventListener('click', createNewConversation);
    
    function createNewConversation() {
        const newId = Date.now().toString();
        conversations[newId] = {
            id: newId,
            title: 'New Chat',
            messages: [],
            createdAt: new Date().toISOString()
        };
        currentConversationId = newId;
        localStorage.setItem('currentConversationId', currentConversationId);
        localStorage.setItem('conversations', JSON.stringify(conversations));
        renderConversation();
        renderChatList();
    }
    
    function switchMode(mode) {
        currentMode = mode;
        textTab.classList.toggle('active', mode === 'text');
        imageTab.classList.toggle('active', mode === 'image');
        modeText.textContent = mode === 'text' ? 'Text Mode' : 'Image Mode';
    }
    
    // Send message handler
    sendBtn.addEventListener('click', sendMessage);
    userInput.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') sendMessage();
    });
    
    function sendMessage() {
        const message = userInput.value.trim();
        if (!message) return;
        
        addMessage('user', message);
        userInput.value = '';
        
        if (currentMode === 'text') {
            fetch('/chat', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({
                    message: message,
                    model: modelSelect.value,
                    role: roleSelect.value
                })
            })
            .then(response => response.json())
            .then(data => {
                addMessage('ai', data.text);
            })
            .catch(error => {
                console.error('Error:', error);
                addMessage('ai', 'Error: Failed to get response');
            });
        } else {
            addMessage('ai', `Generating image for: "${message}"...`);
            fetch('/image', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({prompt: message})
            })
            .then(response => response.json())
            .then(data => {
                // Replace the loading message with image
                const lastMessage = chatHistory.lastChild;
                lastMessage.innerHTML = `
                    <div class="message-header">
                        <i class="fas fa-robot"></i> NeuralChat
                    </div>
                    <div class="image-container">
                        <img src="${data.image_url}" alt="Generated image">
                    </div>
                `;
                conversations[currentConversationId].messages[conversations[currentConversationId].messages.length - 1].content = `<img src="${data.image_url}" alt="Generated image">`;
                saveConversations();
            })
            .catch(error => {
                console.error('Error:', error);
                const lastMessage = chatHistory.lastChild;
                lastMessage.innerHTML = `
                    <div class="message-header">
                        <i class="fas fa-robot"></i> NeuralChat
                    </div>
                    <p>Error: Failed to generate image</p>
                `;
            });
        }
    }
    
    function addMessage(sender, content) {
        const messageDiv = document.createElement('div');
        messageDiv.classList.add('message', `${sender}-message`);
        
        const senderName = sender === 'user' ? 'You' : 'NeuralChat';
        const icon = sender === 'user' ? 'fa-user' : 'fa-robot';
        
        messageDiv.innerHTML = `
            <div class="message-header">
                <i class="fas ${icon}"></i> ${senderName}
            </div>
            ${formatMessage(content)}
        `;
        
        chatHistory.appendChild(messageDiv);
        chatHistory.scrollTop = chatHistory.scrollHeight;
        
        // Add to conversation
        conversations[currentConversationId].messages.push({
            sender: sender,
            content: content,
            timestamp: new Date().toISOString()
        });
        
        // Update conversation title if it's the first message
        if (conversations[currentConversationId].messages.length === 1) {
            conversations[currentConversationId].title = content.substring(0, 30) + (content.length > 30 ? '...' : '');
            renderChatList();
        }
        
        saveConversations();
        
        // Add copy functionality to code blocks
        messageDiv.querySelectorAll('pre').forEach(pre => {
            const button = document.createElement('button');
            button.className = 'copy-btn';
            button.innerHTML = '<i class="fas fa-copy"></i> Copy';
            button.addEventListener('click', () => {
                navigator.clipboard.writeText(pre.textContent);
                button.innerHTML = '<i class="fas fa-check"></i> Copied!';
                setTimeout(() => {
                    button.innerHTML = '<i class="fas fa-copy"></i> Copy';
                }, 2000);
            });
            pre.appendChild(button);
        });
    }
    
    function formatMessage(content) {
        // Convert code blocks
        content = content.replace(/```([\s\S]*?)```/g, '<pre><code>$1</code></pre>');
        // Convert line breaks
        content = content.replace(/\n/g, '<br>');
        return content;
    }
    
    function renderConversation() {
        chatHistory.innerHTML = '';
        const currentConversation = conversations[currentConversationId];
        if (currentConversation) {
            currentConversation.messages.forEach(msg => {
                const messageDiv = document.createElement('div');
                messageDiv.classList.add('message', `${msg.sender}-message`);
                
                const senderName = msg.sender === 'user' ? 'You' : 'NeuralChat';
                const icon = msg.sender === 'user' ? 'fa-user' : 'fa-robot';
                
                messageDiv.innerHTML = `
                    <div class="message-header">
                        <i class="fas ${icon}"></i> ${senderName}
                    </div>
                    ${msg.content.startsWith('<img') ? msg.content : formatMessage(msg.content)}
                `;
                
                chatHistory.appendChild(messageDiv);
            });
            chatHistory.scrollTop = chatHistory.scrollHeight;
        }
    }
    
    function renderChatList() {
        chatList.innerHTML = '';
        Object.values(conversations).forEach(conv => {
            const li = document.createElement('li');
            li.className = 'chat-list-item';
            li.textContent = conv.title;
            if (conv.id === currentConversationId) {
                li.classList.add('active');
            }
            li.addEventListener('click', () => {
                currentConversationId = conv.id;
                localStorage.setItem('currentConversationId', currentConversationId);
                renderConversation();
                renderChatList();
            });
            chatList.appendChild(li);
        });
    }
    
    function saveConversations() {
        localStorage.setItem('conversations', JSON.stringify(conversations));
        localStorage.setItem('currentConversationId', currentConversationId);
    }
    
    // Download conversation
    downloadBtn.addEventListener('click', () => {
        const currentConversation = conversations[currentConversationId];
        if (currentConversation) {
            const dataStr = "data:text/json;charset=utf-8," + 
                encodeURIComponent(JSON.stringify(currentConversation.messages, null, 2));
            const downloadAnchorNode = document.createElement('a');
            downloadAnchorNode.setAttribute("href", dataStr);
            downloadAnchorNode.setAttribute("download", `${currentConversation.title}.json`);
            document.body.appendChild(downloadAnchorNode);
            downloadAnchorNode.click();
            downloadAnchorNode.remove();
        }
    });
});