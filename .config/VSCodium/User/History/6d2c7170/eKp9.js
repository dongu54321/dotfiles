class AIChatApp {
    constructor() {
        this.currentMode = 'text';
        this.currentModel = '';
        this.currentRole = 'helpful assistant';
        this.currentConversationId = null;
        this.isGenerating = false;
        this.conversations = {}; // Local storage for conversations
        
        this.initializeElements();
        this.bindEvents();
        this.loadModels();
        this.loadConversations();
        this.createDefaultConversation();
    }
    
    initializeElements() {
        this.textModeBtn = document.getElementById('textModeBtn');
        this.imageModeBtn = document.getElementById('imageModeBtn');
        this.modelSelect = document.getElementById('modelSelect');
        this.roleSelect = document.getElementById('roleSelect');
        this.downloadBtn = document.getElementById('downloadBtn');
        this.newChatBtn = document.getElementById('newChatBtn');
        this.messageInput = document.getElementById('messageInput');
        this.sendBtn = document.getElementById('sendBtn');
        this.chatContainer = document.getElementById('chatContainer');
        this.conversationsContainer = document.getElementById('conversationsContainer');
    }
    
    bindEvents() {
        this.textModeBtn.addEventListener('click', () => this.switchMode('text'));
        this.imageModeBtn.addEventListener('click', () => this.switchMode('image'));
        this.modelSelect.addEventListener('change', (e) => this.currentModel = e.target.value);
        this.roleSelect.addEventListener('change', (e) => this.currentRole = e.target.value);
        this.downloadBtn.addEventListener('click', () => this.downloadConversation());
        this.newChatBtn.addEventListener('click', () => this.createNewChat());
        this.sendBtn.addEventListener('click', () => this.sendMessage());
        this.messageInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                this.sendMessage();
            }
        });
    }
    
    async loadModels() {
        try {
            const response = await fetch('/api/models/' + this.currentMode);
            const models = await response.json();
            
            this.modelSelect.innerHTML = '<option value="">Default Model</option>';
            models.forEach(model => {
                const option = document.createElement('option');
                option.value = model;
                option.textContent = model;
                this.modelSelect.appendChild(option);
            });
        } catch (error) {
            console.error('Error loading models:', error);
        }
    }
    
    switchMode(mode) {
        this.currentMode = mode;
        
        // Update UI
        this.textModeBtn.classList.toggle('active', mode === 'text');
        this.imageModeBtn.classList.toggle('active', mode === 'image');
        
        // Load appropriate models
        this.loadModels();
        
        // Clear input
        this.messageInput.placeholder = mode === 'text' ? 'Type your message...' : 'Describe the image you want to generate...';
    }
    
    async createNewChat() {
        try {
            const response = await fetch('/api/conversations', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ title: 'New Chat' })
            });
            
            const conversation = await response.json();
            this.currentConversationId = conversation.id;
            
            // Clear chat container
            this.chatContainer.innerHTML = '<div class="welcome-message"><h2>Welcome to Sci-Fi AI Chat</h2><p>Select a mode and start chatting!</p><div class="neon-circle"></div></div>';
            
            this.loadConversations();
        } catch (error) {
            console.error('Error creating new chat:', error);
        }
    }
    
    async loadConversations() {
        try {
            const response = await fetch('/api/conversations');
            const conversations = await response.json();
            
            this.conversationsContainer.innerHTML = '';
            conversations.slice().reverse().forEach(conv => {
                const convElement = document.createElement('div');
                convElement.className = 'conversation-item';
                convElement.innerHTML = `
                    <div class="conversation-title">${conv.title}</div>
                    <div class="conversation-date">${new Date(conv.created_at).toLocaleString()}</div>
                `;
                convElement.addEventListener('click', () => this.loadConversation(conv.id));
                this.conversationsContainer.appendChild(convElement);
            });
        } catch (error) {
            console.error('Error loading conversations:', error);
        }
    }
    
    async loadConversation(conversationId) {
        try {
            const response = await fetch(`/api/conversations/${conversationId}`);
            const conversation = await response.json();
            
            this.currentConversationId = conversation.id;
            
            // Clear and populate chat container
            this.chatContainer.innerHTML = '';
            conversation.messages.forEach(msg => {
                this.addMessageToChat(msg);
            });
        } catch (error) {
            console.error('Error loading conversation:', error);
        }
    }
    
    async createDefaultConversation() {
        await this.createNewChat();
    }
    
    async sendMessage() {
        const message = this.messageInput.value.trim();
        if (!message || this.isGenerating) return;
        
        if (!this.currentConversationId) {
            await this.createNewChat();
        }
        
        this.messageInput.value = '';
        
        // Add user message to chat
        this.addMessageToChat({
            sender: 'user',
            content: message
        });
        
        // Save user message
        await this.saveMessage({
            sender: 'user',
            content: message
        });
        
        // Show loading indicator
        const loadingElement = this.addLoadingIndicator();
        this.isGenerating = true;
        this.sendBtn.disabled = true;
        
        try {
            let response;
            
            if (this.currentMode === 'text') {
                response = await this.generateText(message);
                this.addMessageToChat({
                    sender: 'ai',
                    content: response.response
                });
                await this.saveMessage({
                    sender: 'ai',
                    content: response.response
                });
            } else {
                response = await this.generateImage(message);
                this.addMessageToChat({
                    sender: 'ai',
                    content: '',
                    image_url: response.image_url
                });
                await this.saveMessage({
                    sender: 'ai',
                    content: '',
                    image_url: response.image_url
                });
            }
        } catch (error) {
            this.addMessageToChat({
                sender: 'ai',
                content: 'Sorry, I encountered an error. Please try again.'
            });
            await this.saveMessage({
                sender: 'ai',
                content: 'Sorry, I encountered an error. Please try again.'
            });
        } finally {
            // Remove loading indicator
            if (loadingElement && loadingElement.parentNode) {
                loadingElement.parentNode.removeChild(loadingElement);
            }
            this.isGenerating = false;
            this.sendBtn.disabled = false;
            this.chatContainer.scrollTop = this.chatContainer.scrollHeight;
        }
    }
    
    async generateText(prompt) {
        const response = await fetch('/api/chat/text', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                prompt: prompt,
                model: this.currentModel,
                role: this.currentRole
            })
        });
        return await response.json();
    }
    
    async generateImage(prompt) {
        const response = await fetch('/api/chat/image', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                prompt: prompt,
                model: this.currentModel
            })
        });
        return await response.json();
    }
    
    addMessageToChat(message) {
        // Remove welcome message if it exists
        const welcomeMessage = this.chatContainer.querySelector('.welcome-message');
        if (welcomeMessage) {
            this.chatContainer.innerHTML = '';
        }
        
        const messageElement = document.createElement('div');
        messageElement.className = `message ${message.sender === 'user' ? 'user-message' : 'ai-message'}`;
        
        let content = '';
        if (message.sender === 'user') {
            content = `
                <div class="message-header">
                    <i class="fas fa-user"></i>
                    You
                </div>
                <div class="message-content">${this.escapeHtml(message.content)}</div>
            `;
        } else {
            content = `
                <div class="message-header">
                    <i class="fas fa-robot"></i>
                    AI Assistant
                </div>
                <div class="message-content">${this.formatMessageContent(message.content, message.image_url)}</div>
            `;
        }
        
        messageElement.innerHTML = content;
        this.chatContainer.appendChild(messageElement);
        
        // Add copy button to code blocks
        const codeBlocks = messageElement.querySelectorAll('pre');
        codeBlocks.forEach(block => {
            const copyBtn = document.createElement('button');
            copyBtn.className = 'copy-btn';
            copyBtn.innerHTML = '<i class="fas fa-copy"></i> Copy';
            copyBtn.addEventListener('click', () => this.copyCode(block));
            block.appendChild(copyBtn);
        });
        
        this.chatContainer.scrollTop = this.chatContainer.scrollHeight;
    }
    
    addLoadingIndicator() {
        const loadingElement = document.createElement('div');
        loadingElement.className = 'loading';
        loadingElement.innerHTML = `
            <div class="spinner"></div>
            <span>Generating response...</span>
        `;
        this.chatContainer.appendChild(loadingElement);
        this.chatContainer.scrollTop = this.chatContainer.scrollHeight;
        return loadingElement;
    }
    
    formatMessageContent(content, imageUrl) {
        if (imageUrl) {
            return `
                <div class="image-message">
                    <img src="${imageUrl}" alt="Generated image" onerror="this.src='data:image/svg+xml,<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"400\" height=\"300\" viewBox=\"0 0 400 300\"><rect width=\"400\" height=\"300\" fill=\"%231e1e46\"/><text x=\"200\" y=\"150\" font-family=\"Arial\" font-size=\"20\" fill=\"%2300f3ff\" text-anchor=\"middle\">Image Loading...</text></svg>'">
                </div>
            `;
        }
        
        // Format code blocks
        content = content.replace(/```([\s\S]*?)```/g, '<pre><code>$1</code></pre>');
        
        // Format inline code
        content = content.replace(/`([^`]+)`/g, '<code>$1</code>');
        
        // Format line breaks
        content = content.replace(/\n/g, '<br>');
        
        return content;
    }
    
    async saveMessage(message) {
        if (!this.currentConversationId) return;
        
        try {
            await fetch(`/api/conversations/${this.currentConversationId}/messages`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(message)
            });
        } catch (error) {
            console.error('Error saving message:', error);
        }
    }
    
    async downloadConversation() {
        if (!this.currentConversationId) return;
        
        try {
            window.open(`/api/conversations/${this.currentConversationId}/download`, '_blank');
        } catch (error) {
            console.error('Error downloading conversation:', error);
        }
    }
    
    copyCode(codeBlock) {
        const code = codeBlock.querySelector('code') || codeBlock;
        const text = code.textContent || code.innerText;
        
        navigator.clipboard.writeText(text).then(() => {
            const copyBtn = codeBlock.querySelector('.copy-btn');
            const originalText = copyBtn.innerHTML;
            copyBtn.innerHTML = '<i class="fas fa-check"></i> Copied!';
            setTimeout(() => {
                copyBtn.innerHTML = originalText;
            }, 2000);
        });
    }
    
    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
}

// Initialize the app when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    new AIChatApp();
});