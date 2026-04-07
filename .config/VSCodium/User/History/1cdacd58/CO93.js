import React, { useState } from 'react';
import './App.css';

function App() {
  const [prompt, setPrompt] = useState('');
  const [response, setResponse] = useState('');
  const [conversation, setConversation] = useState([]);
  const [mode, setMode] = useState('text'); // 'text' or 'image'
  const [models, setModels] = useState({ text: [], image: [] });
  const [selectedModel, setSelectedModel] = useState({ text: '', image: '' });

  const fetchModels = async () => {
    const textModelsResponse = await fetch('/api/models/text');
    const imageModelsResponse = await fetch('/api/models/image');
    const textModels = await textModelsResponse.json();
    const imageModels = await imageModelsResponse.json();
    setModels({ text: textModels, image: imageModels });
  };

  React.useEffect(() => {
    fetchModels();
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    let result = '';
    if (mode === 'text') {
      const response = await fetch(`/api/text/${prompt}`);
      const data = await response.json();
      result = data.text;
    } else if (mode === 'image') {
      const response = await fetch(`/api/image/${prompt}`);
      const data = await response.json();
      result = data.image_url;
    }
    setConversation([...conversation, { prompt, response: result }]);
    setPrompt('');
  };

  return (
    <div className="bg-mocha-base text-mocha-text min-h-screen flex">
      <div className="w-64 bg-mocha-mantle p-4">
        <h2 className="text-xl font-bold mb-4">Conversations</h2>
        <button className="bg-mocha-blue text-mocha-base px-4 py-2 rounded mb-4" onClick={() => setConversation([])}>New Chat</button>
        <ul>
          {conversation.map((conv, index) => (
            <li key={index} className="bg-mocha-crust p-2 rounded mb-2">
              <strong>{conv.prompt}</strong>
            </li>
          ))}
        </ul>
      </div>
      <div className="flex-1 p-4">
        <h1 className="text-2xl font-bold mb-4">AI Chat</h1>
        <div className="mb-4">
          <label className="block text-sm font-medium mb-2">Mode:</label>
          <select value={mode} onChange={(e) => setMode(e.target.value)} className="bg-mocha-crust text-mocha-text px-4 py-2 rounded">
            <option value="text">Text</option>
            <option value="image">Image</option>
          </select>
        </div>
        <div className="mb-4">
          <label className="block text-sm font-medium mb-2">Model:</label>
          <select value={selectedModel[mode]} onChange={(e) => setSelectedModel({ ...selectedModel, [mode]: e.target.value })} className="bg-mocha-crust text-mocha-text px-4 py-2 rounded">
            {models[mode].map((model, index) => (
              <option key={index} value={model}>{model}</option>
            ))}
          </select>
        </div>
        <form onSubmit={handleSubmit}>
          <div className="mb-4">
            <label className="block text-sm font-medium mb-2">Prompt:</label>
            <input type="text" value={prompt} onChange={(e) => setPrompt(e.target.value)} className="bg-mocha-crust text-mocha-text px-4 py-2 rounded w-full" />
          </div>
          <button type="submit" className="bg-mocha-green text-mocha-base px-4 py-2 rounded">Generate</button>
        </form>
        <div className="mt-4">
          <h2 className="text-lg font-bold mb-2">Response:</h2>
          {mode === 'text' ? (
            <p>{response}</p>
          ) : (
            <img src={response} alt="Generated" />
          )}
        </div>
      </div>
    </div>
  );
}

export default App;