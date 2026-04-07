class NeuralChat {
    constructor() {
        this.currentConversation = null;
        this.currentMessageType = 'text';
        this.isTyping = false;
        
        this.initializeElements();
        this.bindEvents();
        this.loadConversations();
    }
    
    initializeElements() {
        this.chatContainer = document.getElementById('chatContainer');
        this.messageInput = document.getElementById('messageInput');
        this.sendBtn = document.getElementById('sendBtn');
        this.modelSelect = document.getElementById('modelSelect');
        this.aiRoleSelect = document.getElementById('aiRoleSelect');
        this.newChatBtn = document.getElementById('newChatBtn');
        this.downloadBtn = document.getElementById('downloadBtn');
        this.chatHistory = document.getElementById('chatHistory');
        this.textBtn = document.getElementById('textBtn');
        this.imageBtn = document.getElementById('imageBtn');
    }
    
    bindEvents() {
        this.sendBtn.addEventListener('click', () => this.sendMessage());
        this.messageInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                this.sendMessage();
            }
        });
        this.messageInput.addEventListener('input', this.autoResizeTextarea.bind(this));
        
        this.newChatBtn.addEventListener('click', () => this.createNewChat());
        this.downloadBtn.addEventListener('click', () => this.downloadConversation());
        
        this.textBtn.addEventListener('click', () => this.switchMessageType('text'));
        this.imageBtn.addEventListener('click', () => this.switchMessageType('image'));
        
        // Auto-resize textarea
        this.messageInput.addEventListener('input', this.autoResizeTextarea.bind(this));
    }
    
    autoResizeTextarea() {
        this.messageInput.style.height = 'auto';
        this.messageInput.style.height = Math.min(this.messageInput.scrollHeight, 150) + 'px';
    }
    
    switchMessageType(type) {
        this.currentMessageType = type;
        
        // Update button states
        this.textBtn.classList.toggle('active', type === 'text');
        this.imageBtn.classList.toggle('active', type === 'image');
        
        // Update placeholder
        this.messageInput.placeholder = type === 'text' 
            ? 'Type your message here...' 
            : 'Describe the image you want to generate...';
    }
    
    async sendMessage() {
        const message = this.messageInput.value.trim();
        if (!message || this.isTyping) return;
        
        this.messageInput.value = '';
        this.autoResizeTextarea();
        
        // Add user message to UI
        this.addMessageToUI({
            role: 'user',
            content: message,
            type: 'text'
        });
        
        // Show typing indicator
        this.showTypingIndicator();
        
        try {
            const response = await fetch('/api/chat', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    message: message,
                    model: this.modelSelect.value,
                    ai_role: this.aiRoleSelect.value,
                    type: this.currentMessageType
                })
            });
            
            const data = await response.json();
            
            // Remove typing indicator
            this.removeTypingIndicator();
            
            if (data.message) {
                this.addMessageToUI(data.message);
                this.currentConversation = data.conversation_id;
                this.loadConversations();
            }
        } catch (error) {
            this.removeTypingIndicator();
            this.addMessageToUI({
                role: 'assistant',
                content: `Error: ${error.message}`,
                type: 'text'
            });
        }
    }
    
    addMessageToUI(message) {
        // Remove welcome message if it exists
        const welcomeMessage = this.chatContainer.querySelector('.welcome-message');
        if (welcomeMessage) {
            welcomeMessage.remove();
        }
        
        const messageDiv = document.createElement('div');
        messageDiv.className = `message ${message.role === 'user' ? 'user-message' : 'ai-message'}`;
        
        if (message.type === 'image') {
            messageDiv.innerHTML = `
                <div class="message-content">
                    <img src="${message.content}" alt="Generated image" onerror="this.src='https://via.placeholder.com/400x300?text=Image+Generation+Failed'">
                </div>
            `;
        } else {
            // Process code blocks
            let content = this.escapeHtml(message.content);
            content = content.replace(/\n/g, '<br>');
            content = content.replace(/```([\s\S]*?)```/g, '<pre><code>$1</code><button class="copy-btn">Copy</button></pre>');
            
            messageDiv.innerHTML = `
                <div class="message-content">${content}</div>
            `;
        }
        
        this.chatContainer.appendChild(messageDiv);
        
        // Add copy functionality to code blocks
        const codeBlocks = messageDiv.querySelectorAll('pre');
        codeBlocks.forEach(block => {
            const copyBtn = block.querySelector('.copy-btn');
            if (copyBtn) {
                copyBtn.addEventListener('click', () => {
                    const code = block.querySelector('code').textContent;
                    navigator.clipboard.writeText(code).then(() => {
                        const originalText = copyBtn.textContent;
                        copyBtn.textContent = 'Copied!';
                        setTimeout(() => {
                            copyBtn.textContent = originalText;
                        }, 2000);
                    });
                });
            }
        });
        
        // Scroll to bottom
        this.chatContainer.scrollTop = this.chatContainer.scrollHeight;
    }
    
    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
    
    showTypingIndicator() {
        this.isTyping = true;
        const typingDiv = document.createElement('div');
        typingDiv.className = 'message ai-message message-typing';
        typingDiv.id = 'typingIndicator';
        typingDiv.innerHTML = `
            <div class="typing-indicator">
                <div class="typing-dot"></div>
                <div class="typing-dot"></div>
                <div class="typing-dot"></div>
            </div>
        `;
        this.chatContainer.appendChild(typingDiv);
        this.chatContainer.scrollTop = this.chatContainer.scrollHeight;
    }
    
    removeTypingIndicator() {
        this.isTyping = false;
        const typingIndicator = document.getElementById('typingIndicator');
        if (typingIndicator) {
            typingIndicator.remove();
        }
    }
    
    async createNewChat() {
        try {
            await fetch('/api/new-conversation', { method: 'POST' });
            this.currentConversation = null;
            this.chatContainer.innerHTML = `
                <div class="welcome-message">
                    <h2>Welcome to NeuralChat AI</h2>
                    <p>Select a model and start chatting. You can generate text or images!</p>
                </div>
            `;
            this.loadConversations();
        } catch (error) {
            console.error('Error creating new chat:', error);
        }
    }
    
    async loadConversations() {
        try {
            const response = await fetch('/api/conversations');
            const conversations = await response.json();
            
            this.chatHistory.innerHTML = '';
            conversations.forEach(conv => {
                const convElement = document.createElement('div');
                convElement.className = `chat-item ${conv.id === this.currentConversation ? 'active' : ''}`;
                convElement.innerHTML = `
                    <div class="chat-item-title">${conv.title}</div>
                    <div class="chat-item-date">${new Date(conv.created_at).toLocaleDateString()}</div>
                `;
                convElement.addEventListener('click', () => this.loadConversation(conv.id));
                this.chatHistory.appendChild(convElement);
            });
        } catch (error) {
            console.error('Error loading conversations:', error);
        }
    }
    
    async loadConversation(convId) {
        try {
            const response = await fetch(`/api/conversation/${convId}`);
            const conversation = await response.json();
            
            if (conversation.error) {
                console.error('Conversation not found');
                return;
            }
            
            this.currentConversation = convId;
            this.chatContainer.innerHTML = '';
            
            conversation.messages.forEach(message => {
                this.addMessageToUI(message);
            });
            
            this.loadConversations(); // Update active state in sidebar
        } catch (error) {
            console.error('Error loading conversation:', error);
        }
    }
    
    async downloadConversation() {
        if (!this.currentConversation) {
            alert('No conversation to download');
            return;
        }
        
        try {
            window.open(`/api/download-conversation/${this.currentConversation}`, '_blank');
        } catch (error) {
            console.error('Error downloading conversation:', error);
            alert('Error downloading conversation');
        }
    }
}

// Initialize the app when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    new NeuralChat();
});